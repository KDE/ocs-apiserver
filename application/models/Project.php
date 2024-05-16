<?php
/**
 * open content store api - part of Opendesktop.org platform project <https://www.opendesktop.org>.
 *
 * Copyright (c) 2016-2024 pling GmbH.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

class Application_Model_Project extends Application_Model_DbTable_Project
{

    const FILTER_NAME_PROJECT_ID_NOT_IN = 'project_id_not_in';
    const FILTER_NAME_RANKING = 'ranking';
    const FILTER_NAME_CATEGORY = 'category';
    const FILTER_NAME_PACKAGETYPE = 'package_type';
    const FILTER_NAME_MEMBER = 'member';
    const FILTER_NAME_ORDER = 'order';
    const FILTER_NAME_LOCATION = 'location';

    const ITEM_TYPE_DUMMY = 0;
    const ITEM_TYPE_PRODUCT = 1;
    const ITEM_TYPE_UPDATE = 2;

    /**
     * @param $projectId
     *
     * @return array
     */
    public function getGalleryPictureSources($projectId) {
        $galleryPictureTable = new Application_Model_DbTable_ProjectGalleryPicture();
        $stmt = $galleryPictureTable->select()->where('project_id = ?', $projectId)->order(array('sequence'));

        $pics = array();
        foreach ($galleryPictureTable->fetchAll($stmt) as $pictureRow) {
            $pics[] = $pictureRow['picture_src'];
        }

        return $pics;
    }

    protected function _getCatIds($catids) {
        $sqlwhereCat = "";
        $sqlwhereSubCat = "";

        $idCategory = explode(',', $catids);
        if (false === is_array($idCategory)) {
            $idCategory = array($idCategory);
        }

        $sqlwhereCat .= implode(',', $idCategory);

        $modelCategory = new Application_Model_DbTable_ProjectCategory();
        $subCategories = $modelCategory->fetchChildElements($idCategory);

        if (count($subCategories) > 0) {
            foreach ($subCategories as $element) {
                $sqlwhereSubCat .= "{$element['project_category_id']},";
            }
        }

        return $sqlwhereSubCat . $sqlwhereCat;
    }

    /**
     * @param array $data
     *
     * @return Zend_Db_Table_Rowset_Abstract
     */
    protected function generateRowSet($data) {
        $classRowSet = $this->getRowsetClass();

        return new $classRowSet(array(
                                    'table'    => $this,
                                    'rowClass' => $this->getRowClass(),
                                    'stored'   => true,
                                    'data'     => $data
                                ));
    }


}