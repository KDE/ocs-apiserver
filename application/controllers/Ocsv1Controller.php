<?php
/**
 *  ocs-apiserver
 *
 *  Copyright 2016 by pling GmbH.
 *
 *    This file is part of ocs-apiserver.
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU Affero General Public License as
 *    published by the Free Software Foundation, either version 3 of the
 *    License, or (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU Affero General Public License for more details.
 *
 *    You should have received a copy of the GNU Affero General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Created: 01.12.2017
 */

/**
 * What changes from official OCS v1 spec
 *
 * OCS specification:
 * http://www.freedesktop.org/wiki/Specifications/open-collaboration-services/
 *
 * ----
 *
 * Allow delimiter ',' of value of parameter 'categories'
 *
 * Example:
 * /content/data?categories=1,2,3
 * /content/data?categories=1x2x3
 *
 * ----
 *
 * Additional URL queries to '/content/data'
 *
 * xdg_types
 * package_types
 *
 * Example:
 * /content/data?xdg_types=icons,themes,wallpapers
 * /content/data?package_types=1,2,3
 *
 * package_types:
 * 1 = AppImage
 * 2 = Android (apk)
 * 3 = OS X compatible
 * 4 = Windows executable
 * 5 = Debian
 * 6 = Snappy
 * 7 = Flatpak
 * 8 = Electron-Webapp
 * 9 = Arch
 * 10 = open/Suse
 * 11 = Redhat
 * 12 = Source Code
 *
 * ----
 *
 * Additional data field of '/content/categories'
 *
 * display_name
 * parent_id
 * xdg_type
 *
 * ----
 *
 * Additional data field of '/content/data'
 *
 * xdg_type
 * download_package_type{n}
 * download_package_arch{n}
 *
 * ----
 *
 * Additional data field of '/content/download'
 *
 * download_package_type
 * download_package_arch
 *
 * ----
 *
 * Additional API method for preview picture
 *
 * /content/previewpic/{contentid}
 *
 * Example:
 * /content/previewpic/123456789
 * /content/previewpic/123456789?size=medium
 */
class Ocsv1Controller extends Zend_Controller_Action
{

    const COMMENT_TYPE_CONTENT = 1;
    const COMMENT_TYPE_FORUM = 4;
    const COMMENT_TYPE_KNOWLEDGE = 7;
    const COMMENT_TYPE_EVENT = 8;

    const DOWNLOAD_PERIOD_VALIDITY = 12; // hours

    const CACHE_PERIOD_VALIDITY = 1; // hour

    protected $_authData = null;

    protected $_uriScheme = 'https';

    protected $_format = 'xml';

    protected $_config = array(
        'id'         => 'opendesktop.org',
        'location'   => 'https://www.opendesktop.org/ocs/v1/',
        'name'       => 'opendesktop.org',
        'icon'       => '',
        'termsofuse' => 'https://www.opendesktop.org/terms',
        'register'   => 'https://www.opendesktop.org/register',
        'version'    => '1.7',
        'website'    => 'www.opendesktop.org',
        'host'       => 'www.opendesktop.org',
        'contact'    => 'contact@opendesktop.org',
        'ssl'        => true,
        'user_host'  => 'pling.me'
    );

    protected $_params = array();

    public function init()
    {
        parent::init();
        $this->_initUriScheme();
        $this->_initRequestParamsAndFormat();
        $this->_initConfig();
        $this->_initResponseHeader();
    }

    protected function _initUriScheme()
    {
        if (isset($_SERVER['HTTPS']) && ($_SERVER['HTTPS'] == 'on' || $_SERVER['HTTPS'] === '1')) {
            $this->_uriScheme = 'https';
        } else {
            $this->_uriScheme = 'http';
        }
    }

    /**
     * @throws Zend_Exception
     */
    protected function _initRequestParamsAndFormat()
    {
        // Set request parameters
        switch (strtoupper($_SERVER['REQUEST_METHOD'])) {
            case 'GET':
                $this->_params = $_GET;
                break;
            case 'PUT':
                parse_str(file_get_contents('php://input'), $_PUT);
                $this->_params = $_PUT;
                break;
            case 'POST':
                $this->_params = $_POST;
                break;
            default:
                Zend_Registry::get('logger')->err(__METHOD__ . ' - request method not supported - ' . $_SERVER['REQUEST_METHOD']);
                exit('request method not supported');
        }

        // Set format option
        if (isset($this->_params['format']) && strtolower($this->_params['format']) == 'json') {
            $this->_format = 'json';
        }
    }

    /**
     * @throws Zend_Exception
     */
    protected function _initConfig()
    {
        $clientConfig = $this->_loadClientConfig();

        $credentials = '';
        if (!empty($_SERVER['PHP_AUTH_USER']) && !empty($_SERVER['PHP_AUTH_PW'])) {
            $credentials = $_SERVER['PHP_AUTH_USER'] . ':' . $_SERVER['PHP_AUTH_PW'] . '@';
        }

        $baseUri = $this->_uriScheme . '://' . $credentials . $_SERVER['SERVER_NAME'];

        $webSite = Zend_Registry::isRegistered('store_host') ? Zend_Registry::get('store_host') : 'www.opendesktop.org';

        //Mask api.kde-look.org to store.kde.org
        if (strpos($_SERVER['SERVER_NAME'], 'api.kde-look.org') !== false) {
            $webSite = 'store.kde.org';
        }
        if (strpos($_SERVER['SERVER_NAME'], 'api2.kde-look.org') !== false) {
            $webSite = 'store.kde.org';
        }
        if (strpos($_SERVER['SERVER_NAME'], '165.227.165.131') !== false) {
            $webSite = 'store.kde.org';
        }

        $this->_config = array(
                'id'         => $_SERVER['SERVER_NAME'],
                'location'   => $baseUri . '/ocs/v1/',
                'name'       => $clientConfig['head']['browser_title'],
                'icon'       => $baseUri . $clientConfig['logo'],
                'termsofuse' => $baseUri . '/content/terms',
                'register'   => $baseUri . '/register',
                'website'    => $webSite,
                'host'       => $_SERVER['SERVER_NAME']
            ) + $this->_config;
    }

    /**
     * @return array|null
     * @throws Zend_Exception
     */
    protected function _loadClientConfig()
    {
        $clientConfigReader = new Application_Model_ClientConfig($this->_getNameForStoreClient());
        $clientConfigReader->loadClientConfig();

        return $clientConfigReader->getConfig();
    }

    /**
     * Returns the name for the store client.
     * If no name were found, the name for the standard store client will be returned.
     *
     * @return string
     * @throws Zend_Exception
     */
    protected function _getNameForStoreClient()
    {
        $clientName = Zend_Registry::get('config')->settings->client->default->name; // default client
        if (Zend_Registry::isRegistered('store_config_name')) {
            $clientName = Zend_Registry::get('store_config_name');
        }

        return $clientName;
    }

    protected function _initResponseHeader()
    {
        $duration = 1800; // in seconds
        $expires = gmdate("D, d M Y H:i:s", time() + $duration) . " GMT";

        $this->getResponse()
             ->setHeader('X-FRAME-OPTIONS', 'SAMEORIGIN', true)//             ->setHeader('Last-Modified', $modifiedTime, true)
             ->setHeader('Expires', $expires, true)->setHeader('Pragma', 'cache', true)
             ->setHeader('Cache-Control', 'max-age=1800, public', true)
        ;
    }

    public function indexAction()
    {
        $this->_sendErrorResponse(999, 'unknown request');
    }

    /**
     * @param        $statuscode
     * @param string $message
     */
    protected function _sendErrorResponse($statuscode, $message = '')
    {
        if ($this->_format == 'json') {
            $response = array(
                'status'     => 'failed',
                'statuscode' => $statuscode,
                'message'    => $message
            );
        } else {
            $response = array(
                'meta' => array(
                    'status'     => array('@text' => 'failed'),
                    'statuscode' => array('@text' => $statuscode),
                    'message'    => array('@text' => $message)
                )
            );
        }

        $this->_sendResponse($response, $this->_format);
    }

    /**
     * @param        $response
     * @param string $format
     * @param string $xmlRootTag
     */
    protected function _sendResponse($response, $format = 'xml', $xmlRootTag = 'ocs')
    {
        header('Pragma: public');
        header('Cache-Control: cache, must-revalidate');
        $duration = 1800; // in seconds
        $expires = gmdate("D, d M Y H:i:s", time() + $duration) . " GMT";
        header('Expires: ' . $expires);
        if ($format == 'json') {
            header('Content-Type: application/json; charset=UTF-8');
            echo json_encode($response);
        } else {
            header('Content-Type: application/xml; charset=UTF-8');
            echo $this->_convertXmlDom($response, $xmlRootTag)->saveXML();
        }

        exit;
    }

    /**
     * @param                 $values
     * @param string          $tagName
     * @param DOMNode|null    $dom
     * @param DOMElement|null $element
     *
     * @return DomDocument|DOMNode
     */
    protected function _convertXmlDom($values, $tagName = 'data', DOMNode &$dom = null, DOMElement &$element = null)
    {
        if (!$dom) {
            $dom = new DomDocument('1.0', 'UTF-8');
        }
        if (!$element) {
            $element = $dom->appendChild($dom->createElement($tagName));
        }
        if (is_array($values) || is_object($values)) {
            foreach ($values as $key => $value) {
                if (is_array($value) || is_object($value)) {
                    $isHash = false;
                    foreach ($value as $_key => $_value) {
                        if (ctype_digit((string)$_key)) {
                            $isHash = true;
                        }
                        break;
                    }
                    if ($isHash) {
                        $this->_convertXmlDom($value, $key, $dom, $element);
                        continue;
                    }
                    if (ctype_digit((string)$key)) {
                        $key = $tagName;
                    }
                    $childElement = $element->appendChild($dom->createElement($key));
                    $this->_convertXmlDom($value, $key, $dom, $childElement);
                } else {
                    if ($key == '@text') {
                        if (is_bool($value)) {
                            $value = var_export($value, true);
                        }
                        $element->appendChild($dom->createTextNode($value));
                    } else if ($key == '@cdata') {
                        if (is_bool($value)) {
                            $value = var_export($value, true);
                        }
                        $element->appendChild($dom->createCDATASection($value));
                    } else {
                        if (is_bool($value)) {
                            $value = var_export($value, true);
                        }
                        $element->setAttribute($key, $value);
                    }
                }
            }
        }

        return $dom;
    }

    public function providersAction()
    {
        // As providers.xml
        $response = array(
            'provider' => array(
                'id'         => array('@text' => $this->_config['id']),
                'location'   => array('@text' => $this->_config['location']),
                'name'       => array('@text' => $this->_config['name']),
                'icon'       => array('@text' => $this->_config['icon']),
                'termsofuse' => array('@text' => $this->_config['termsofuse']),
                'register'   => array('@text' => $this->_config['register']),
                'services'   => array(
                    'person'  => array('ocsversion' => $this->_config['version']),
                    'content' => array('ocsversion' => $this->_config['version'])
                )
            )
        );

        $this->_sendResponse($response, 'xml', 'providers');
    }

    public function configAction()
    {
        if ($this->_format == 'json') {
            $response = array(
                'status'     => 'ok',
                'statuscode' => 100,
                'message'    => '',
                'data'       => array(
                    'version' => $this->_config['version'],
                    'website' => $this->_config['website'],
                    'host'    => $this->_config['host'],
                    'contact' => $this->_config['contact'],
                    'ssl'     => $this->_config['ssl']
                )
            );
        } else {
            $response = array(
                'meta' => array(
                    'status'     => array('@text' => 'ok'),
                    'statuscode' => array('@text' => 100),
                    'message'    => array('@text' => '')
                ),
                'data' => array(
                    'version' => array('@text' => $this->_config['version']),
                    'website' => array('@text' => $this->_config['website']),
                    'host'    => array('@text' => $this->_config['host']),
                    'contact' => array('@text' => $this->_config['contact']),
                    'ssl'     => array('@text' => $this->_config['ssl'])
                )
            );
        }

        $this->_sendResponse($response, $this->_format);
    }

    public function personcheckAction()
    {
        $identity = null;
        $credential = null;
        if (!empty($this->_params['login'])) {
            $identity = $this->_params['login'];
        }
        if (!empty($this->_params['password'])) {
            $credential = $this->_params['password'];
        }

        if (!$identity) {
            $this->_sendErrorResponse(101, 'please specify all mandatory fields');
        } else {
            if (!$this->_authenticateUser($identity, $credential)) {
                $this->_sendErrorResponse(102, 'login not valid');
            }
        }

        if ($this->_format == 'json') {
            $response = array(
                'status'     => 'ok',
                'statuscode' => 100,
                'message'    => '',
                'data'       => array(
                    array(
                        'details'  => 'check',
                        'personid' => $this->_authData->username
                    )
                )
            );
        } else {
            $response = array(
                'meta' => array(
                    'status'     => array('@text' => 'ok'),
                    'statuscode' => array('@text' => 100),
                    'message'    => array('@text' => '')
                ),
                'data' => array(
                    'person' => array(
                        'details'  => 'check',
                        'personid' => array('@text' => $this->_authData->username)
                    )
                )
            );
        }

        $this->_sendResponse($response, $this->_format);
    }

    /**
     * @param null $identity
     * @param null $credential
     * @param bool $force
     *
     * @return bool
     */
    protected function _authenticateUser($identity = null, $credential = null, $force = false)
    {
        ////////////////////////////////////////////////////////
        // BasicAuth enabled testing site workaround
        if (strrpos($_SERVER['SERVER_NAME'], 'pling.ws') !== false
            || strrpos($_SERVER['SERVER_NAME'], 'pling.cc') !== false
            || strrpos($_SERVER['SERVER_NAME'], 'pling.to') !== false
            || strrpos($_SERVER['SERVER_NAME'], 'ocs-store.com') !== false) {
            $authData = new stdClass;
            $authData->username = 'dummy';
            $this->_authData = $authData;

            return true;
        }
        ////////////////////////////////////////////////////////

        if (!$identity && !empty($_SERVER['PHP_AUTH_USER'])) {
            // Will set user identity or API-Key
            $identity = $_SERVER['PHP_AUTH_USER'];
        }
        if (!$credential && !empty($_SERVER['PHP_AUTH_PW'])) {
            $credential = $_SERVER['PHP_AUTH_PW'];
        }

        $loginMethod = null;
        //if ($identity && !$credential) {
        //    $loginMethod = 'api-key';
        //}

        if ($identity && ($credential || $loginMethod == 'api-key')) {
            $authModel = new Application_Model_Authorization();
            $authData = $authModel->getAuthDataFromApi($identity, $credential, $loginMethod);
            if ($authData) {
                $this->_authData = $authData;

                return true;
            }
        }

        if ($force) {
            //header('WWW-Authenticate: Basic realm="Your valid user account or api key"');
            header('WWW-Authenticate: Basic realm="Your valid user account"');
            header('HTTP/1.0 401 Unauthorized');
            exit;
        }

        return false;
    }

    public function personselfAction()
    {
        $this->persondataAction(true);
    }

    public function persondataAction($self = false)
    {
        if (!$this->_authenticateUser()) {
            $this->_sendErrorResponse(101, 'person not found');
        }

        $tableMember = new Application_Model_Member();

        // Self data or specific person data
        if ($self || $this->getParam('personid')) {
            if ($self) {
                $username = $this->_authData->username;
            } else {
                if ($this->getParam('personid')) {
                    $username = $this->getParam('personid');
                }
            }

            $member = $tableMember->findActiveMemberByIdentity($username);

            if (!$member) {
                $this->_sendErrorResponse(101, 'person not found');
            }

            $profilePage = $this->_uriScheme . '://' . $this->_config['user_host'] . '/member/' . $member->member_id;

            if ($this->_format == 'json') {
                $response = array(
                    'status'     => 'ok',
                    'statuscode' => 100,
                    'message'    => '',
                    'data'       => array(
                        array(
                            'details'              => 'full',
                            'personid'             => $member->username,
                            'privacy'              => 0,
                            'privacytext'          => 'public',
                            'firstname'            => $member->firstname,
                            'lastname'             => $member->lastname,
                            'gender'               => '',
                            'communityrole'        => '',
                            'homepage'             => $member->link_website,
                            'company'              => '',
                            'avatarpic'            => $member->profile_image_url,
                            'avatarpicfound'       => true,
                            'bigavatarpic'         => $member->profile_image_url,
                            'bigavatarpicfound'    => true,
                            'birthday'             => '',
                            'jobstatus'            => '',
                            'city'                 => $member->city,
                            'country'              => $member->country,
                            'latitude'             => '',
                            'longitude'            => '',
                            'ircnick'              => '',
                            'ircchannels'          => '',
                            'irclink'              => '',
                            'likes'                => '',
                            'dontlikes'            => '',
                            'interests'            => '',
                            'languages'            => '',
                            'programminglanguages' => '',
                            'favouritequote'       => '',
                            'favouritemusic'       => '',
                            'favouritetvshows'     => '',
                            'favouritemovies'      => '',
                            'favouritebooks'       => '',
                            'favouritegames'       => '',
                            'description'          => $member->biography,
                            'profilepage'          => $profilePage
                        )
                    )
                );
            } else {
                $response = array(
                    'meta' => array(
                        'status'     => array('@text' => 'ok'),
                        'statuscode' => array('@text' => 100),
                        'message'    => array('@text' => '')
                    ),
                    'data' => array(
                        'person' => array(
                            'details'              => 'full',
                            'personid'             => array('@text' => $member->username),
                            'privacy'              => array('@text' => 0),
                            'privacytext'          => array('@text' => 'public'),
                            'firstname'            => array('@text' => $member->firstname),
                            'lastname'             => array('@text' => $member->lastname),
                            'gender'               => array('@text' => ''),
                            'communityrole'        => array('@text' => ''),
                            'homepage'             => array('@text' => $member->link_website),
                            'company'              => array('@text' => ''),
                            'avatarpic'            => array('@text' => $member->profile_image_url),
                            'avatarpicfound'       => array('@text' => true),
                            'bigavatarpic'         => array('@text' => $member->profile_image_url),
                            'bigavatarpicfound'    => array('@text' => true),
                            'birthday'             => array('@text' => ''),
                            'jobstatus'            => array('@text' => ''),
                            'city'                 => array('@text' => $member->city),
                            'country'              => array('@text' => $member->country),
                            'latitude'             => array('@text' => ''),
                            'longitude'            => array('@text' => ''),
                            'ircnick'              => array('@text' => ''),
                            'ircchannels'          => array('@text' => ''),
                            'irclink'              => array('@text' => ''),
                            'likes'                => array('@text' => ''),
                            'dontlikes'            => array('@text' => ''),
                            'interests'            => array('@text' => ''),
                            'languages'            => array('@text' => ''),
                            'programminglanguages' => array('@text' => ''),
                            'favouritequote'       => array('@text' => ''),
                            'favouritemusic'       => array('@text' => ''),
                            'favouritetvshows'     => array('@text' => ''),
                            'favouritemovies'      => array('@text' => ''),
                            'favouritebooks'       => array('@text' => ''),
                            'favouritegames'       => array('@text' => ''),
                            'description'          => array('@text' => $member->biography),
                            'profilepage'          => array('@text' => $profilePage)
                        )
                    )
                );
            }

            $this->_sendResponse($response, $this->_format);
        } // Find a specific list of persons
        else {
            $limit = 10; // 1 - 100
            $offset = 0;

            $tableMemberSelect = $tableMember->select()->where('is_active = ?', 1)->where('is_deleted = ?', 0);

            if (!empty($this->_params['name'])) {
                $isSearchable = false;
                foreach (explode(' ', $this->_params['name']) as $keyword) {
                    if ($keyword && strlen($keyword) > 2) {
                        $tableMemberSelect->where('username LIKE ?' . ' OR firstname LIKE ?' . ' OR lastname LIKE ?', "%$keyword%");
                        $isSearchable = true;
                    }
                }
                if (!$isSearchable) {
                    $tableMemberSelect->where('username LIKE ?' . ' OR firstname LIKE ?' . ' OR lastname LIKE ?',
                        "%{$this->_params['name']}%");
                }
            }
            if (!empty($this->_params['country'])) {
                $tableMemberSelect->where('country = ?', $this->_params['country']);
            }
            if (!empty($this->_params['city'])) {
                $tableMemberSelect->where('city = ?', $this->_params['city']);
            }
            if (!empty($this->_params['description'])) {
                $isSearchable = false;
                foreach (explode(' ', $this->_params['name']) as $keyword) {
                    if ($keyword && strlen($keyword) > 2) {
                        $tableMemberSelect->where('biography LIKE ?', "%$keyword%");
                        $isSearchable = true;
                    }
                }
                if (!$isSearchable) {
                    $tableMemberSelect->where('biography LIKE ?', "%$this->_params['description']}%");
                }
            }
            if (!empty($this->_params['pc'])) {
            }
            if (!empty($this->_params['software'])) {
            }
            if (!empty($this->_params['longitude'])) {
            }
            if (!empty($this->_params['latitude'])) {
            }
            if (!empty($this->_params['distance'])) {
            }
            if (!empty($this->_params['attributeapp'])) {
            }
            if (!empty($this->_params['attributekey'])) {
            }
            if (!empty($this->_params['attributevalue'])) {
            }
            if (isset($this->_params['pagesize'])
                && ctype_digit((string)$this->_params['pagesize'])
                && $this->_params['pagesize'] > 0
                && $this->_params['pagesize'] < 101) {
                $limit = $this->_params['pagesize'];
            }
            if (isset($this->_params['page'])
                && ctype_digit((string)$this->_params['page'])) {
                // page parameter: the first page is 0
                $offset = $limit * $this->_params['page'];
            }

            $members = $tableMember->fetchAll($tableMemberSelect->limit($limit, $offset));

            $tableMemberSelect->reset('columns');
            $tableMemberSelect->reset('limitcount');
            $tableMemberSelect->reset('limitoffset');

            $count = $tableMember->fetchRow($tableMemberSelect->columns(array('count' => 'COUNT(*)')));

            if ($count['count'] > 1000) {
                $this->_sendErrorResponse(102, 'more than 1000 people found.' . ' it is not allowed to fetch such a big resultset.'
                    . ' please specify more search conditions');
            }

            if ($this->_format == 'json') {
                $response = array(
                    'status'       => 'ok',
                    'statuscode'   => 100,
                    'message'      => '',
                    'totalitems'   => $count['count'],
                    'itemsperpage' => $limit,
                    'data'         => array()
                );
            } else {
                $response = array(
                    'meta' => array(
                        'status'       => array('@text' => 'ok'),
                        'statuscode'   => array('@text' => 100),
                        'message'      => array('@text' => ''),
                        'totalitems'   => array('@text' => $count['count']),
                        'itemsperpage' => array('@text' => $limit)
                    ),
                    'data' => array()
                );
            }

            if (!count($members)) {
                $this->_sendResponse($response, $this->_format);
            }

            $personsList = array();
            foreach ($members as $member) {
                if ($this->_format == 'json') {
                    $personsList[] = array(
                        'details'       => 'summary',
                        'personid'      => $member->username,
                        'privacy'       => 0,
                        'privacytext'   => 'public',
                        'firstname'     => $member->firstname,
                        'lastname'      => $member->lastname,
                        'gender'        => '',
                        'communityrole' => '',
                        'company'       => '',
                        'city'          => $member->city,
                        'country'       => $member->country
                    );
                } else {
                    $personsList[] = array(
                        'details'       => 'summary',
                        'personid'      => array('@text' => $member->username),
                        'privacy'       => array('@text' => 0),
                        'privacytext'   => array('@text' => 'public'),
                        'firstname'     => array('@text' => $member->firstname),
                        'lastname'      => array('@text' => $member->lastname),
                        'gender'        => array('@text' => ''),
                        'communityrole' => array('@text' => ''),
                        'company'       => array('@text' => ''),
                        'city'          => array('@text' => $member->city),
                        'country'       => array('@text' => $member->country)
                    );
                }
            }

            if ($this->_format == 'json') {
                $response['data'] = $personsList;
            } else {
                $response['data'] = array('person' => $personsList);
            }

            $this->_sendResponse($response, $this->_format);
        }
    }

    public function contentcategoriesAction()
    {
        /** @var Zend_Cache_Core $cache */
        $cache = Zend_Registry::get('cache');
        $cacheName = 'api_content_categories_'.md5($this->_getNameForStoreClient());

        $debugMode = (int)$this->getParam('debug') ? (int)$this->getParam('debug') : false;

        if (false == ($categoriesList = $cache->load($cacheName))) {
            $categoriesList = $this->_buildCategories();
            $cache->save($categoriesList, $cacheName, array(), 1800);
        }

        if ($this->_format == 'json') {
            $response = array(
                'status'     => 'ok',
                'statuscode' => 100,
                'message'    => '',
                'totalitems' => count($categoriesList),
                'data'       => array()
            );
            if (!empty($categoriesList)) {
                $response['data'] = $categoriesList;
            }
        } else {
            $response = array(
                'meta' => array(
                    'status'     => array('@text' => 'ok'),
                    'statuscode' => array('@text' => 100),
                    'message'    => array('@text' => ''),
                    'totalitems' => array('@text' => count($categoriesList))
                ),
                'data' => array()
            );
            if (!empty($categoriesList)) {
                $response['data'] = array('category' => $categoriesList);
            }
        }

        if($debugMode) {
            $response['meta']['debug']['store_client_name'] = $this->_getNameForStoreClient();
            $response['meta']['debug']['param_store_client_name'] = $this->getParam('domain_store_id');
        }

        $this->_sendResponse($response, $this->_format);
    }

    /**
     * @return array
     */
    protected function _buildCategories()
    {
        $modelCategoryTree = new Application_Model_ProjectCategory();
        $tree = $modelCategoryTree->fetchCategoryTreeCurrentStore();

        return $this->buildResponseTree($tree);
    }

    /**
     * @param array $tree
     *
     * @return array
     */
    protected function buildResponseTree($tree)
    {
        $result = array();
        foreach ($tree as $element) {
            if ($this->_format == 'json') {
                $result[] = array(
                    'id'           => $element['id'],
                    'name'         => (false === empty($element['name_legacy'])) ? $element['name_legacy'] : $element['title'],
                    'display_name' => $element['title'],
                    'parent_id'    => (false === empty($element['parent_id'])) ? $element['parent_id'] : '',
                    'xdg_type'     => (false === empty($element['xdg_type'])) ? $element['xdg_type'] : ''
                );
            } else {
                $result[] = array(
                    'id'           => array('@text' => $element['id']),
                    'name'         => array(
                        '@text' => (false === empty($element['name_legacy'])) ? $element['name_legacy'] : $element['title']
                    ),
                    'display_name' => array('@text' => $element['title']),
                    'parent_id'    => array('@text' => (false === empty($element['parent_id'])) ? $element['parent_id'] : ''),
                    'xdg_type'     => array('@text' => (false === empty($element['xdg_type'])) ? $element['xdg_type'] : '')
                );
            }
            if ($element['has_children']) {
                $sub_tree = $this->buildResponseTree($element['children']);
                $result = array_merge($result, $sub_tree);
            }
        }

        return $result;
    }

    public function contentdataAction()
    {
        $this->_authenticateUser();

        $pploadApi = new Ppload_Api(array(
            'apiUri'   => PPLOAD_API_URI,
            'clientId' => PPLOAD_CLIENT_ID,
            'secret'   => PPLOAD_SECRET
        ));
        $previewPicSize = array(
            'width'  => 770,
            'height' => 540,
            'crop'   => 0
        );
        $smallPreviewPicSize = array(
            'width'  => 100,
            'height' => 100,
            'crop'   => 0
        );

        $debugMode = (int)$this->getParam('debug') ? (int)$this->getParam('debug') : false;

        // Specific content data
        $requestedId = (int)$this->getParam('content_id') ? (int)$this->getParam('content_id') : null;
        if ($requestedId) {
            $response = $this->fetchContent($requestedId, $previewPicSize, $smallPreviewPicSize, $pploadApi);

            $this->_sendResponse($response, $this->_format);
        } // Gets a list of a specific set of contents
        else {
            $response = $this->fetchCategoryContent($previewPicSize, $smallPreviewPicSize, $pploadApi, $debugMode);

            $this->_sendResponse($response, $this->_format);
        }
    }

    /**
     * @param int        $contentId
     * @param array      $previewPicSize
     * @param array      $smallPreviewPicSize
     * @param Ppload_Api $pploadApi
     *
     * @return array
     * @throws Zend_Cache_Exception
     * @throws Zend_Exception
     */
    protected function fetchContent(
        $contentId,
        $previewPicSize,
        $smallPreviewPicSize,
        $pploadApi
    ) {
        /** @var Zend_Cache_Core $cache */
        $cache = Zend_Registry::get('cache');
        $cacheName = 'api_fetch_content_by_id_' . $contentId;
        
        if (($response = $cache->load($cacheName))) {
            return $response;
        }

        $tableProject = new Application_Model_Project();
        $tableProjectSelect = $this->_buildProjectSelect($tableProject);

        $project = $tableProject->fetchRow($tableProjectSelect->where('project.project_id = ?', $contentId));

        if (!$project) {
            $this->_sendErrorResponse(101, 'content not found');
        }

        $project->title = Application_Model_HtmlPurify::purify($project->title);
        $project->description = Application_Model_BBCode::renderHtml(Application_Model_HtmlPurify::purify($project->description));
        $project->version = Application_Model_HtmlPurify::purify($project->version);

        $categoryXdgType = '';
        if (!empty($project->cat_xdg_type)) {
            $categoryXdgType = $project->cat_xdg_type;
        }

        $created = date('c', strtotime($project->created_at));
        $changed = date('c', strtotime($project->changed_at));

        $previewPage = $this->_uriScheme . '://' . $this->_config['website'] . '/p/' . $project->project_id;

        $donationPage = $previewPage;
        if (empty($project->paypal_mail) && empty($project->dwolla_id)) {
            $donationPage = '';
        }

        list($previewPics, $smallPreviewPics) = $this->getGalleryPictures($project, $previewPicSize, $smallPreviewPicSize);

        $downloads = $project->count_downloads_hive;
        list($downloadItems, $downloads) = $this->getPPLoadInfo($project, $pploadApi, $downloads);
        
        $score = $project->laplace_score;
        $score = $score/100;

        if ($this->_format == 'json') {
            $response = array(
                'status'     => 'ok',
                'statuscode' => 100,
                'message'    => '',
                'data'       => array(
                    array(
                        'details'              => 'full',
                        'id'                   => $project->project_id,
                        'name'                 => $project->title,
                        'version'              => $project->version,
                        'typeid'               => $project->project_category_id,
                        'typename'             => $project->cat_title,
                        'xdg_type'             => $categoryXdgType,
                        'language'             => '',
                        'personid'             => $project->username,
                        'created'              => $created,
                        'changed'              => $changed,
                        'downloads'            => $downloads,
                        'score'                => $score,
                        'summary'              => '',
                        'description'          => $project->description,
                        'changelog'            => '',
                        'feedbackurl'          => $previewPage,
                        'homepage'             => $previewPage,
                        'homepagetype'         => '',
                        'donationpage'         => $donationPage,
                        'comments'             => $project->count_comments,
                        'commentspage'         => $previewPage,
                        'fans'                 => null,
                        'fanspage'             => '',
                        'knowledgebaseentries' => null,
                        'knowledgebasepage'    => '',
                        'depend'               => '',
                        'preview1'             => $previewPage,
                        'icon'                 => '',
                        'video'                => '',
                        'detailpage'           => $previewPage,
                        'ghns_excluded'        => $project->ghns_excluded,
                        'tags'                 => $project->tags
                    ) + $previewPics + $smallPreviewPics + $downloadItems
                )
            );
        } else {
            foreach ($previewPics as $key => $value) {
                $previewPics[$key] = array('@text' => $value);
            }
            foreach ($smallPreviewPics as $key => $value) {
                $smallPreviewPics[$key] = array('@text' => $value);
            }
            if ($downloadItems) {
                foreach ($downloadItems as $key => $value) {
                    $downloadItems[$key] = array('@text' => $value);
                }
            }
            $response = array(
                'meta' => array(
                    'status'     => array('@text' => 'ok'),
                    'statuscode' => array('@text' => 100),
                    'message'    => array('@text' => '')
                ),
                'data' => array(
                    'content' => array(
                            'details'              => 'full',
                            'id'                   => array('@text' => $project->project_id),
                            'name'                 => array('@text' => $project->title),
                            'version'              => array('@text' => $project->version),
                            'typeid'               => array('@text' => $project->project_category_id),
                            'typename'             => array('@text' => $project->cat_title),
                            'xdg_type'             => array('@text' => $categoryXdgType),
                            'language'             => array('@text' => ''),
                            'personid'             => array('@text' => $project->username),
                            'created'              => array('@text' => $created),
                            'changed'              => array('@text' => $changed),
                            'downloads'            => array('@text' => $downloads),
                            'score'                => array('@text' => $score),
                            'summary'              => array('@text' => ''),
                            'description'          => array('@cdata' => $project->description),
                            'changelog'            => array('@text' => ''),
                            'feedbackurl'          => array('@text' => $previewPage),
                            'homepage'             => array('@text' => $previewPage),
                            'homepagetype'         => array('@text' => ''),
                            'donationpage'         => array('@text' => $donationPage),
                            'comments'             => array('@text' => $project->count_comments),
                            'commentspage'         => array('@text' => $previewPage),
                            'fans'                 => array('@text' => null),
                            'fanspage'             => array('@text' => ''),
                            'knowledgebaseentries' => array('@text' => null),
                            'knowledgebasepage'    => array('@text' => ''),
                            'depend'               => array('@text' => ''),
                            'preview1'             => array('@text' => $previewPage),
                            'icon'                 => array('@text' => ''),
                            'video'                => array('@text' => ''),
                            'detailpage'           => array('@text' => $previewPage),
                            'ghns_excluded'        => array('@text' => $project->ghns_excluded),
                            'tags'                 => array('@text' => $project->tags)
                        ) + $previewPics + $smallPreviewPics + $downloadItems
                )
            );
        }

        $cache->save($response, $cacheName);

        return $response;
    }

    /**
     * @param Zend_Db_Table $tableProject
     *
     * @param bool          $withSqlCalcFoundRows
     *
     * @return Zend_Db_Table_Select
     * @throws Zend_Db_Select_Exception
     */
    protected function _buildProjectSelect($tableProject, $withSqlCalcFoundRows = false)
    {
        $tableProjectSelect = $tableProject->select();
        if ($withSqlCalcFoundRows) {
            $tableProjectSelect->from(array('project' => 'stat_projects'), array(new Zend_Db_Expr('SQL_CALC_FOUND_ROWS *')));
        } else {
            $tableProjectSelect->from(array('project' => 'stat_projects'));
        }
        $tableProjectSelect->setIntegrityCheck(false)->columns(array(
            '*',
            'member_username' => 'username',
            'category_title'  => 'cat_title',
            'xdg_type'        => 'cat_xdg_type',
            'name_legacy'     => 'cat_name_legacy',
            new Zend_Db_Expr("(select count(1) as num_files from ppload.ppload_files f where f.active = 1 and f.collection_id = project.ppload_collection_id group by f.collection_id) as num_files"),
            new Zend_Db_Expr("(select count(1) AS `amount` from `stat_downloads_24h` `s` WHERE s.collection_id = project.ppload_collection_id group by `s`.`collection_id`) as num_dls")
        ))->where('project.status = ?', Application_Model_Project::PROJECT_ACTIVE)->where('project.ppload_collection_id IS NOT NULL')
        ;
        $tableProjectSelect->having('num_files > 0');

        return $tableProjectSelect;
    }

    /**
     * @param Zend_Db_Table_Row_Abstract $project
     * @param array                      $previewPicSize
     * @param array                      $smallPreviewPicSize
     *
     * @return array
     * @throws Zend_Cache_Exception
     * @throws Zend_Exception
     */
    protected function getGalleryPictures($project, $previewPicSize, $smallPreviewPicSize)
    {
        /** @var Zend_Cache_Core $cache */
        $cache = Zend_Registry::get('cache');
        $cacheName = 'api_fetch_gallery_pics_' . $project->project_id;

        if (($previews = $cache->load($cacheName))) {
            return $previews;
        }

        $viewHelperImage = new Application_View_Helper_Image();
        $previewPics = array(
            'previewpic1' => $viewHelperImage->Image($project->image_small, $previewPicSize)
        );
        $smallPreviewPics = array(
            'smallpreviewpic1' => $viewHelperImage->Image($project->image_small, $smallPreviewPicSize)
        );

        $tableProject = new Application_Model_Project();
        $galleryPics = $tableProject->getGalleryPictureSources($project->project_id);
        if ($galleryPics) {
            $i = 2;
            foreach ($galleryPics as $galleryPic) {
                $previewPics['previewpic' . $i] = $viewHelperImage->Image($galleryPic, $previewPicSize);
                $smallPreviewPics['smallpreviewpic' . $i] = $viewHelperImage->Image($galleryPic, $smallPreviewPicSize);
                $i++;
            }
        }

        $cache->save(array($previewPics, $smallPreviewPics), $cacheName);

        return array($previewPics, $smallPreviewPics);
    }

    /**
     * @param Zend_Db_Table_Row_Abstract $project
     * @param Ppload_Api                 $pploadApi
     * @param int                        $downloads
     * @param string                     $fileIds
     *
     * @return array
     * @throws Zend_Cache_Exception
     * @throws Zend_Exception
     */
    protected function getPPLoadInfo($project, $pploadApi, $downloads, $fileIds = null)
    {
        $downloadItems = array();
        
        if (empty($project->ppload_collection_id)) {
            return array($downloadItems, $downloads);
        }

        /** @var Zend_Cache_Core $cache */
        $cache = Zend_Registry::get('cache');
        $cacheName = 'api_ppload_collection_by_id_' . $project->ppload_collection_id;

        if($fileIds && count($fileIds) > 0) {
            $cacheName .=  '_' . md5($fileIds);
        }

        if (false !== ($pploadInfo = $cache->load($cacheName))) {
            return $pploadInfo;
        }
        
        $tagTable = new Application_Model_Tags();
        
        //if filter for fileIds
        //if($fileIds && count($fileIds) > 0) {
        //    $filesRequest['ids'] = $fileIds;
        //}
        
        //Load Files from DB
        $pploadFileTable = new Application_Model_DbTable_PploadFiles();
        $files = $pploadFileTable->fetchAllActiveFilesForFileInfo($project->ppload_collection_id, $fileIds);
        
        $sql = "    select  *
                     from ppload.ppload_files f 
                     where f.collection_id = :collection_id 
                     and f.active = 1
                   ";        
        if(null != $fileIds && count($fileIds) > 0) {
           $sql .= " and f.id in (".$fileIds.")";
        }
        
        $packageTypeTags = $tagTable->getAllFilePackageTypeTags();
        $architectureTags = $tagTable->getAllFileArchitectureTags();
        
        $i = 1;
        foreach ($files as $file) {
            //get File-Tags from DB
            $fileTagArray = $tagTable->getTagsAsArray($file['id'], $tagTable::TAG_TYPE_FILE);
            
            //create ppload download hash: secret + collection_id + expire-timestamp
            list($timestamp, $hash) = $this->createDownloadHash($project);
            
            //$tags = $this->_parseFileTags($file->tags);
            
            //collect tags
            $fileTags = "";
            
            //mimetype
            $fileTags .= "data##mimetype=".$file['type'].",";
            
            //$fileTags .= "tags=".$fileTagArray->__toString().",";
            
            
            $tagTable = new Application_Model_Tags();
            
            foreach ($fileTagArray as $tag) {
                if(in_array($tag, $packageTypeTags)) {
                    $fileTags .= "application##packagetype=".$tag . ",";
                } else if(in_array($tag, $architectureTags)) {
                    $fileTags .= "application##architecture=".$tag.",";
                }
            }

            $fileTags = rtrim($fileTags,",");


            $downloads += (int)$file['downloaded_count'];

            $downloadLink =
                PPLOAD_API_URI . 'files/download/id/' . $file['id'] . '/s/' . $hash . '/t/' . $timestamp . '/o/1/' . $file['name'];
            $downloadItems['downloadway' . $i] = 1;
            $downloadItems['downloadtype' . $i] = '';
            $downloadItems['downloadprice' . $i] = '0';
            $downloadItems['downloadlink' . $i] = $downloadLink;
            $downloadItems['downloadname' . $i] = $file['name'];
            $downloadItems['downloadsize' . $i] = round($file['size'] / 1024);
            $downloadItems['downloadgpgfingerprint' . $i] = '';
            $downloadItems['downloadgpgsignature' . $i] = '';
            $downloadItems['downloadpackagename' . $i] = '';
            $downloadItems['downloadrepository' . $i] = '';
            $downloadItems['download_package_type' . $i] = null;
            $downloadItems['download_package_arch' . $i] = null;
            //$downloadItems['downloadtags' . $i] = empty($tags['filetags']) ? '' : implode(',', $tags['filetags']);
            $downloadItems['downloadtags' . $i] = empty($fileTags) ? '' : $fileTags;
            $i++;
            
        }
        
        
        
        /**
         * 
         *
        $filesRequest = array(
            'collection_id'     => ltrim($project->ppload_collection_id, '!'),
            'ocs_compatibility' => 'compatible',
            'perpage'           => 100
        );

        

        $filesResponse = $pploadApi->getFiles($filesRequest);
        
        
        if (isset($filesResponse->status) && $filesResponse->status == 'success') {
            $i = 1;
            foreach ($filesResponse->files as $file) {
                //create ppload download hash: secret + collection_id + expire-timestamp
                list($timestamp, $hash) = $this->createDownloadHash($project);
                $tags = $this->_parseFileTags($file->tags);
                //collect tags
                $fileTags = "";
                //$fileTags .= "tags=".$file->tags."##";
                //mimetype
                $fileTags .= "data##mimetype=".$file->type.",";
                $tagTable = new Application_Model_Tags();

                if(isset($tags['packagetypeid']) && !empty($tags['packagetypeid'])) {
                    $packageTypeId = $tags['packagetypeid'];
                    $tag = $tagTable->getTag($packageTypeId);
                    if(isset($tag)) {
                        $fileTags .= "application##packagetype=".$tag['tag_name'] . ",";
                    }
                }
                if(isset($tags['architectureid']) && !empty($tags['architectureid'])) {
                    $architectureId = $tags['architectureid'];
                    $tag = $tagTable->getTag($architectureId);
                    if(isset($tag)) {
                        $fileTags .= "application##architecture=".$tag['tag_name'].",";
                    }
                }

                $fileTags = rtrim($fileTags,",");


                $downloads += (int)$file->downloaded_count;

                $downloadLink =
                    PPLOAD_API_URI . 'files/download/id/' . $file->id . '/s/' . $hash . '/t/' . $timestamp . '/o/1/' . $file->name;
                $downloadItems['downloadway' . $i] = 1;
                $downloadItems['downloadtype' . $i] = '';
                $downloadItems['downloadprice' . $i] = '0';
                $downloadItems['downloadlink' . $i] = $downloadLink;
                $downloadItems['downloadname' . $i] = $file->name;
                $downloadItems['downloadsize' . $i] = round($file->size / 1024);
                $downloadItems['downloadgpgfingerprint' . $i] = '';
                $downloadItems['downloadgpgsignature' . $i] = '';
                $downloadItems['downloadpackagename' . $i] = '';
                $downloadItems['downloadrepository' . $i] = '';
                $downloadItems['download_package_type' . $i] = $tags['packagetypeid'];
                $downloadItems['download_package_arch' . $i] = $tags['architectureid'];
                //$downloadItems['downloadtags' . $i] = empty($tags['filetags']) ? '' : implode(',', $tags['filetags']);
                $downloadItems['downloadtags' . $i] = empty($fileTags) ? '' : $fileTags;
                $i++;
            }
        }
        */
        

        $cache->save(array($downloadItems, $downloads), $cacheName, array(), (self::CACHE_PERIOD_VALIDITY * 3600));

        return array($downloadItems, $downloads);
    }

    /**
     * @param $project
     *
     * @return array
     */
    protected function createDownloadHash($project)
    {
        //create ppload download hash: secret + collection_id + expire-timestamp
        $salt = PPLOAD_DOWNLOAD_SECRET;
        $collectionID = $project->ppload_collection_id;
        $timestamp = time() + (3600 * self::DOWNLOAD_PERIOD_VALIDITY);
        $hash = md5($salt . $collectionID . $timestamp);

        return array($timestamp, $hash);
    }

    /**
     * @param string $fileTags
     *
     * @return array
     */
    protected function _parseFileTags($fileTags)
    {
        $tags = explode(',', $fileTags);
        $parsedTags = array(
            'link'          => '',
            'licensetype'   => '',
            'packagetypeid' => '',
            'architectureid' => '',
            'packagearch'   => '',
            'filetags'      => ''
        );
        foreach ($tags as $tag) {
            $tag = trim($tag);
            if (strpos($tag, 'link##') === 0) {
                $parsedTags['link'] = urldecode(str_replace('link##', '', $tag));
            } else if (strpos($tag, 'licensetype-') === 0) {
                $parsedTags['licensetype'] = str_replace('licensetype-', '', $tag);
            } else if (strpos($tag, 'packagetypeid-') === 0) {
                $parsedTags['packagetypeid'] = str_replace('packagetypeid-', '', $tag);
            } else if (strpos($tag, 'architectureid-') === 0) {
                $parsedTags['architectureid'] = str_replace('architectureid-', '', $tag);
            } else if (strpos($tag, 'packagearch-') === 0) {
                $parsedTags['packagearch'] = str_replace('packagearch-', '', $tag);
            } else if (strpos($tag, '@@@') === 0) {
                $strTags = substr($tag, 3, strlen($tag) - 2);
                $parsedTags['filetags'] = explode('@@', $strTags);
            }
        }

        return $parsedTags;
    }

    /**
     * @param array      $previewPicSize
     * @param array      $smallPreviewPicSize
     * @param Ppload_Api $pploadApi
     * @param boolean    $debugMode Is debug mode
     *
     * @return array
     * @throws Zend_Cache_Exception
     * @throws Zend_Db_Select_Exception
     * @throws Zend_Exception
     */
    protected function fetchCategoryContent(
        $previewPicSize,
        $smallPreviewPicSize,
        $pploadApi,
        $debugMode
    ) {
        $limit = 10; // 1 - 100
        $offset = 0;

        $tableProject = new Application_Model_Project();
        $tableProjectSelect = $this->_buildProjectSelect($tableProject, true);

        $storeTags = Zend_Registry::isRegistered('config_store_tags') ? Zend_Registry::get('config_store_tags') : null;

        /*
        if ($storeTags) {
            $tableProjectSelect->join(array(
                'tags' => new Zend_Db_Expr('(SELECT DISTINCT project_id FROM stat_project_tagids WHERE tag_id in ('
                    . implode(',', $storeTags) . '))')
            ), 'project.project_id = tags.project_id', array());
        }
         * 
         */
        
        if ($storeTags) {
            $tagList = $storeTags;
            //build where statement für projects
            $selectAnd = $tableProject->select();
            $selectAndFiles = $tableProject->select();
            
            $tableTags = new Application_Model_Tags();
            $possibleFileTags = $tableTags->fetchAllFileTagNamesAsArray();

            if(!is_array($tagList)) {
                $tagList = array($tagList);
            }
            
            foreach($tagList as $item) {
                #and
                $selectAnd->where('find_in_set(?, tag_ids)', $item);
                if (in_array($item, $possibleFileTags)) {
                    $selectAndFiles->where('find_in_set(?, tag_ids)', $item);
                } else {
                    $selectAndFiles->where("1=1");
                }
            }
            $tableProjectSelect->where(implode(' ', $selectAnd->getPart('where')));
        }

        if (false === empty($this->_params['categories'])) {
            // categories parameter: values separated by ","
            // legacy OCS API compatible: values separated by "x"
            if (strpos($this->_params['categories'], ',') !== false) {
                $catList = explode(',', $this->_params['categories']);
            } else {
                $catList = explode('x', $this->_params['categories']);
            }

            $modelProjectCategories = new Application_Model_DbTable_ProjectCategory();
            $allCategories = array_merge($catList, $modelProjectCategories->fetchChildIds($catList));
            $tableProjectSelect->where('project.project_category_id IN (?)', $allCategories);
        }

        if (!empty($this->_params['xdg_types'])) {
            // xdg_types parameter: values separated by ","
            $xdgTypeList = explode(',', $this->_params['xdg_types']);
            $tableProjectSelect->where('category.xdg_type IN (?)', $xdgTypeList);
        }


        /**
         * deprecated: we use tags now
        if (!empty($this->_params['package_types'])) {
            // package_types parameter: values separated by ","
            if( strpos( $this->_params['package_types'], ',' ) !== false) {
                $packageTypeList = explode(',', $this->_params['package_types']);
            } else {
                $packageTypeList = array($this->_params['package_types']);
            }

            $select1 = $tableProject->select();
            foreach($packageTypeList as $item) {
                $select1->orWhere('find_in_set(?, package_shortnames)', $item);
            }
            $tableProjectSelect->where(implode(' ', $select1->getPart('where')));

        }
        *
        */

        $hasSearchPart = false;
        if (false === empty($this->_params['search'])) {
            foreach (explode(' ', $this->_params['search']) as $keyword) {
                if ($keyword && strlen($keyword) > 2) {
                    $tableProjectSelect->where('project.title LIKE ? OR project.description LIKE ?', "%$keyword%");
                    $hasSearchPart = true;
                }
            }
        }

        if (false === empty($this->_params['tags'])) {
            // tags parameter: values separated by "," and | for or filter
            if( strpos( $this->_params['tags'], ',' ) !== false) {
                $tagList = explode(',', $this->_params['tags']);
            } else {
                $tagList = array($this->_params['tags']);
            }

            //build where statement für projects
            $selectAnd = $tableProject->select();
            $selectAndFiles = $tableProject->select();

            $tableTags = new Application_Model_Tags();
            $possibleFileTags = $tableTags->fetchAllFileTagNamesAsArray();

            foreach($tagList as $item) {
                if( strpos( $item, '|' ) !== false) {
                    #or
                    $selectOr = $tableProject->select();
                    $selectOrFiles = $tableProject->select();
                    $tagListOr = explode('|', $item);
                    foreach($tagListOr as $itemOr) {
                        $selectOr->orWhere('find_in_set(?, tags)', $itemOr);
                        if (in_array($itemOr, $possibleFileTags)) {
                            $selectOrFiles->orWhere('find_in_set(?, tags)', $itemOr);
                        }
                    }
                    $selectAnd->where(implode(' ', $selectOr->getPart('where')));

                    $selectAndFiles->where(implode(' ', $selectOrFiles->getPart('where')));
                } else {
                    #and
                    $selectAnd->where('find_in_set(?, tags)', $item);
                    if (in_array($item, $possibleFileTags)) {
                        $selectAndFiles->where('find_in_set(?, tags)', $item);
                    } else {
                        $selectAndFiles->where("1=1");
                    }
                }

            }
            $tableProjectSelect->where(implode(' ', $selectAnd->getPart('where')));
        } else {
            $selectAndFiles = $tableProject->select();
            $selectAndFiles->where("1=1");
        }

        if (!empty($this->_params['ghns_excluded'])) {
            $tableProjectSelect->where('project.ghns_excluded = ?', $this->_params['ghns_excluded']);
        }

        if (!empty($this->_params['user'])) {
            $tableProjectSelect->where('member.username = ?', $this->_params['user']);
        }

        if (!empty($this->_params['external'])) {
        }

        if (!empty($this->_params['distribution'])) {
            // distribution parameter: comma separated list of ids
        }

        if (!empty($this->_params['license'])) {
            // license parameter: comma separated list of ids
        }

        if (!empty($this->_params['sortmode'])) {
            // sortmode parameter: new|alpha|high|down
            switch (strtolower($this->_params['sortmode'])) {
                case 'new':
                    $tableProjectSelect->order('project.created_at DESC');
                    break;
                case 'alpha':
                    $tableProjectSelect->order('project.title ASC');
                    break;
                case 'high':
                    $tableProjectSelect->order(new Zend_Db_Expr('laplace_score(project.count_likes,project.count_dislikes) DESC'));
                    break;
                case 'down':
                    /**
                    $tableProjectSelect->joinLeft(array('stat_downloads_quarter_year' => 'stat_downloads_quarter_year'),
                        'project.project_id = stat_downloads_quarter_year.project_id', array());
                    $tableProjectSelect->order('stat_downloads_quarter_year.amount DESC');
                     * 
                     */
                    /*
                    $tableProjectSelect->joinLeft(array('stat_downloads_24h' => 'stat_downloads_24h_v'),
                        'project.ppload_collection_id = stat_downloads_24h.collection_id', array());
                    $tableProjectSelect->order('stat_downloads_24h.amount DESC');
                    $tableProjectSelect->order('project.created_at DESC');
                     * 
                     */
                    $tableProjectSelect->order('num_dls DESC');
                    $tableProjectSelect->order('project.created_at DESC');
                    
                    break;
                default:
                    break;
            }
        }

        if (isset($this->_params['pagesize'])
            && ctype_digit((string)$this->_params['pagesize'])
            && $this->_params['pagesize'] > 0
            && $this->_params['pagesize'] < 101) {
            $limit = $this->_params['pagesize'];
        }

        if (isset($this->_params['page'])
            && ctype_digit((string)$this->_params['page'])) {
            // page parameter: the first page is 0
            $offset = $limit * $this->_params['page'];
        }

        $tableProjectSelect->limit($limit, $offset);


        /** @var Zend_Cache_Core $cache */
        $cache = Zend_Registry::get('cache');
        $storeName = Zend_Registry::get('store_config')->name;
        $cacheName = 'api_fetch_category_' . md5($tableProjectSelect->__toString() . '_' . $selectAndFiles->__toString() . '_' . $storeName);
        $cacheNameCount = 'api_fetch_category_' . md5($tableProjectSelect->__toString() . '_' . $selectAndFiles->__toString() . '_' . $storeName) . '_count';
        $contentsList = false;
        $count = 0;
        $isFromCache = false;

        if (false === $hasSearchPart) {
            $contentsList = $cache->load($cacheName);
            $count = $cache->load($cacheNameCount);
        }

        if (false == $contentsList) {
            $projects = $tableProject->fetchAll($tableProjectSelect);
            $counter = $tableProject->getAdapter()->fetchRow('select FOUND_ROWS() AS counter');
            $count = $counter['counter'];
            
            if(count($projects)>0) {
                $contentsList = $this->_buildContentList($previewPicSize, $smallPreviewPicSize, $pploadApi, $projects, implode(' ', $selectAndFiles->getPart('where')));
                if (false === $hasSearchPart) {
                    $cache->save($contentsList, $cacheName, array(), 1800);
                    $cache->save($count, $cacheNameCount, array(), 1800);
                }
            } else {
                $contentsList = array();
            }
        } else {
            $isFromCache = true;
        }
        
        if ($this->_format == 'json') {
            $response = array(
                'status'       => 'ok',
                'statuscode'   => 100,
                'message'      => '',
                'totalitems'   => $count,
                'itemsperpage' => $limit,
                'data'         => $contentsList
            );
        } else {
            $response = array(
                'meta' => array(
                    'status'       => array('@text' => 'ok'),
                    'statuscode'   => array('@text' => 100),
                    'message'      => array('@text' => ''),
                    'totalitems'   => array('@text' => $count),
                    'itemsperpage' => array('@text' => $limit)
                ),
                'data' => array()
            );
            if(count($contentsList)>0) {
                $response['data']['content'] = $contentsList;
            }
        }
        
        

        if($debugMode) {
            $response['meta']['debug']['is_from_cache_now'] = $isFromCache;
            $response['meta']['debug']['select_project'] = $tableProjectSelect->__toString();
            $response['meta']['debug']['select_files'] = $selectAndFiles->__toString();
            $response['meta']['debug']['store_client_name'] = $this->_getNameForStoreClient();
            $response['meta']['debug']['param_store_client_name'] = $this->getParam('domain_store_id');
            $response['meta']['debug']['hello'] = 'World';
        }

        return $response;
    }

    /**
     * @param $previewPicSize
     * @param $smallPreviewPicSize
     * @param $pploadApi
     * @param $projects
     *
     * @return array
     * @throws Zend_Cache_Exception
     * @throws Zend_Exception
     */
    protected function _buildContentList($previewPicSize, $smallPreviewPicSize, $pploadApi, $projects, $selectWhereString)
    {
        $contentsList = array();
        $helperTruncate = new Application_View_Helper_Truncate();
        $selectWhereString = ' AND ' . $selectWhereString;
        foreach ($projects as $project) {
            $project->description =
                $helperTruncate->truncate(Application_Model_BBCode::renderHtml(Application_Model_HtmlPurify::purify($project->description)),
                    300);

            $categoryXdgType = '';
            if (!empty($project->xdg_type)) {
                $categoryXdgType = $project->xdg_type;
            }

            $created = date('c', strtotime($project->created_at));
            $changed = date('c', strtotime($project->changed_at));

            $previewPage = $this->_uriScheme . '://' . $this->_config['website'] . '/p/' . $project->project_id;

            list($previewPics, $smallPreviewPics) = $this->getGalleryPictures($project, $previewPicSize, $smallPreviewPicSize);

            $downloads = $project->count_downloads_hive;

            //Get Files from OCS-API
            //get the list of file-ids from tags-filter
            $fileIds = "";
            $filesList = array();
            $tableTags = new Application_Model_Tags();
            $filesList = $tableTags->getFilesForTags($project->project_id, $selectWhereString);

            //if there is a tag filter and we have found any files, skip this project
            if($selectWhereString <> ' AND (1=1)' && (empty($filesList) || count($filesList) == 0)) {
                //echo "No files found for project ".$project->project_id;
                continue;
            }
            /*
            if($selectWhereString <> ' AND (1=1)') {
                $tableTags = new Application_Model_Tags();
                $filesList = $tableTags->getFilesForTags($project->project_id, $selectWhereString);

                //if there is a tag filter and we have not found any files, skip this project
                if($selectWhereString <> ' AND (1=1)' && (empty($filesList) || count($filesList) == 0)) {
                    //echo "No files found for project ".$project->project_id;
                    continue;
                }
            }*/

            foreach ($filesList as $file) {
                $fileIds .= $file['file_id'].',';
            }
            $fileIds = rtrim($fileIds,",");

            //var_dump($fileIds);

            list($downloadItems, $downloads) = $this->getPPLoadInfo($project, $pploadApi, $downloads, $fileIds);

            //If no files available, do not show this project
            if (empty($downloadItems)) {
                continue; // jump to next product
            }
            
            $score = $project->laplace_score;
            $score = $score/100;

            if ($this->_format == 'json') {
                $contentsList[] = array(
                        'details'     => 'summary',
                        'id'          => $project->project_id,
                        'name'        => $project->title,
                        'version'     => $project->version,
                        'typeid'      => $project->project_category_id,
                        'typename'    => $project->cat_title,
                        'xdg_type'    => $categoryXdgType,
                        'language'    => '',
                        'personid'    => $project->member_username,
                        'created'     => $created,
                        'changed'     => $changed,
                        'downloads'   => $downloads,
                        'score'       => $score,
                        'summary'     => '',
                        'description' => $project->description,
                        'comments'    => $project->count_comments,
                        'ghns_excluded' => $project->ghns_excluded,
                        'preview1'    => $previewPage,
                        'detailpage'  => $previewPage,
                        'tags'        => $project->tags
                    ) + $previewPics + $smallPreviewPics + $downloadItems;
            } else {
                foreach ($previewPics as $key => $value) {
                    $previewPics[$key] = array('@text' => $value);
                }
                foreach ($smallPreviewPics as $key => $value) {
                    $smallPreviewPics[$key] = array('@text' => $value);
                }
                if ($downloadItems) {
                    foreach ($downloadItems as $key => $value) {
                        $downloadItems[$key] = array('@text' => $value);
                    }
                }
                $contentsList[] = array(
                        'details'     => 'summary',
                        'id'          => array('@text' => $project->project_id),
                        'name'        => array('@text' => $project->title),
                        'version'     => array('@text' => $project->version),
                        'typeid'      => array('@text' => $project->project_category_id),
                        'typename'    => array('@text' => $project->cat_title),
                        'xdg_type'    => array('@text' => $categoryXdgType),
                        'language'    => array('@text' => ''),
                        'personid'    => array('@text' => $project->member_username),
                        'created'     => array('@text' => $created),
                        'changed'     => array('@text' => $changed),
                        'downloads'   => array('@text' => $downloads),
                        'score'       => array('@text' => $score),
                        'summary'     => array('@text' => ''),
                        'description' => array('@cdata' => $project->description),
                        'comments'    => array('@text' => $project->count_comments),
                        'ghns_excluded' => array('@text' => $project->ghns_excluded),
                        'preview1'    => array('@text' => $previewPage),
                        'detailpage'  => array('@text' => $previewPage),
                        'tags'        => array('@text' => $project->tags)
                    ) + $previewPics + $smallPreviewPics + $downloadItems;
            }
        }

        return $contentsList;
    }

    public function contentdownloadAction()
    {
        $this->_authenticateUser();

        $project = null;
        $file = null;

        if ($this->getParam('contentid')) {
            $tableProject = new Application_Model_Project();
            $project = $tableProject->fetchRow($tableProject->select()->where('project_id = ?', $this->getParam('contentid'))
                                                            ->where('status = ?', Application_Model_Project::PROJECT_ACTIVE));
        }

        if (!$project) {
            $this->_sendErrorResponse(101, 'content not found');
        }
        
        if (((int)$this->getParam('itemid')) === 0) {
                $this->_sendErrorResponse(103, 'content item not found');
            }
        
        if ($project->ppload_collection_id
            && $this->getParam('itemid')
            && ctype_digit((string)$this->getParam('itemid'))) {
            $tagTable = new Application_Model_Tags();

            //Load Files from DB
            $pploadFileTable = new Application_Model_DbTable_PploadFiles();
            $files = $pploadFileTable->fetchActiveFileWithIndex($project->ppload_collection_id, $this->getParam('itemid'));
            
            if (empty($files)) {
                $this->_sendErrorResponse(103, 'content item not found');
            }

            $packageTypeTags = $tagTable->getAllFilePackageTypeTags();
            $architectureTags = $tagTable->getAllFileArchitectureTags();

            $fileTags = "";
            foreach ($files as $file) {
                //get File-Tags from DB
                $fileTagArray = $tagTable->getTagsAsArray($file['id'], $tagTable::TAG_TYPE_FILE);

                //create ppload download hash: secret + collection_id + expire-timestamp
                list($timestamp, $hash) = $this->createDownloadHash($project);

                //$tags = $this->_parseFileTags($file->tags);

                //collect tags
                $fileTags = "";

                //mimetype
                $fileTags .= "data##mimetype=".$file['type'].",";

                //$fileTags .= "tags=".$fileTagArray->__toString().",";


                $tagTable = new Application_Model_Tags();

                foreach ($fileTagArray as $tag) {
                    if(in_array($tag, $packageTypeTags)) {
                        $fileTags .= "application##packagetype=".$tag . ",";
                    } else if(in_array($tag, $architectureTags)) {
                        $fileTags .= "application##architecture=".$tag.",";
                    }
                }

                $fileTags = rtrim($fileTags,",");

                $downloadLink =
                    PPLOAD_API_URI . 'files/download/id/' . $file['id'] . '/s/' . $hash . '/t/' . $timestamp . '/o/1/' . $file['name'];
                
                if ($this->_format == 'json') {
                    $response = array(
                        'status'     => 'ok',
                        'statuscode' => 100,
                        'message'    => '',
                        'data'       => array(
                            array(
                                'details'               => 'download',
                                'downloadway'           => 1,
                                'downloadlink'          => $downloadLink,
                                'mimetype'              => $file['type'],
                                'gpgfingerprint'        => '',
                                'gpgsignature'          => '',
                                'packagename'           => '',
                                'repository'            => '',
                                'download_package_type' => null,
                                'download_package_arch' => null,
                                'downloadtags'          => empty($fileTags) ? '' : $fileTags
                            )
                        )
                    );
                } else {
                    $response = array(
                        'meta' => array(
                            'status'     => array('@text' => 'ok'),
                            'statuscode' => array('@text' => 100),
                            'message'    => array('@text' => '')
                        ),
                        'data' => array(
                            'content' => array(
                                'details'               => 'download',
                                'downloadway'           => array('@text' => 1),
                                'downloadlink'          => array('@text' => $downloadLink),
                                'mimetype'              => array('@text' => $file['type']),
                                'gpgfingerprint'        => array('@text' => ''),
                                'gpgsignature'          => array('@text' => ''),
                                'packagename'           => array('@text' => ''),
                                'repository'            => array('@text' => ''),
                                'download_package_type' => array('@text' => ''),
                                'download_package_arch' => array('@text' => ''),
                                'downloadtags'          => array('@text' => empty($fileTags) ? '' : $fileTags)
                            )
                        )
                    );
                }
                
            }
        
        }
        
        
        
        
        /**
        if ($project->ppload_collection_id
            && $this->getParam('itemid')
            && ctype_digit((string)$this->getParam('itemid'))) {
            
            $filesRequest = array(
                'collection_id'     => ltrim($project->ppload_collection_id, '!'),
                'ocs_compatibility' => 'compatible',
                'perpage'           => 1,
                'page'              => $this->getParam('itemid')
            );
            $filesResponse = $pploadApi->getFiles($filesRequest);
            if (isset($filesResponse->status)
                && $filesResponse->status == 'success') {
                $i = 0;
                $file = $filesResponse->files->$i;
            }
        }

        if (!$file) {
            $this->_sendErrorResponse(103, 'content item not found');
        }
        list($timestamp, $hash) = $this->createDownloadHash($project);

        $tags = $this->_parseFileTags($file->tags);
        $downloadLink =
            PPLOAD_API_URI . 'files/download/id/' . $file->id . '/s/' . $hash . '/t/' . $timestamp . '/o/1/' . $file->name;

        if ($this->_format == 'json') {
            $response = array(
                'status'     => 'ok',
                'statuscode' => 100,
                'message'    => '',
                'data'       => array(
                    array(
                        'details'               => 'download',
                        'downloadway'           => 1,
                        'downloadlink'          => $downloadLink,
                        'mimetype'              => $file->type,
                        'gpgfingerprint'        => '',
                        'gpgsignature'          => '',
                        'packagename'           => '',
                        'repository'            => '',
                        'download_package_type' => $tags['packagetypeid'],
                        'download_package_arch' => $tags['packagearch'],
                        'downloadtags'          => empty($tags['filetags']) ? '' : implode(',', $tags['filetags'])
                    )
                )
            );
        } else {
            $response = array(
                'meta' => array(
                    'status'     => array('@text' => 'ok'),
                    'statuscode' => array('@text' => 100),
                    'message'    => array('@text' => '')
                ),
                'data' => array(
                    'content' => array(
                        'details'               => 'download',
                        'downloadway'           => array('@text' => 1),
                        'downloadlink'          => array('@text' => $downloadLink),
                        'mimetype'              => array('@text' => $file->type),
                        'gpgfingerprint'        => array('@text' => ''),
                        'gpgsignature'          => array('@text' => ''),
                        'packagename'           => array('@text' => ''),
                        'repository'            => array('@text' => ''),
                        'download_package_type' => array('@text' => $tags['packagetypeid']),
                        'download_package_arch' => array('@text' => $tags['packagearch']),
                        'downloadtags'          => array('@text' => empty($tags['filetags']) ? '' : implode(',', $tags['filetags']))
                    )
                )
            );
        }
         * 
         */

        $this->_sendResponse($response, $this->_format);
    }

    public function contentpreviewpicAction()
    {
        $this->_authenticateUser();

        $project = null;

        if ($this->getParam('contentid')) {
            $tableProject = new Application_Model_Project();
            $project = $tableProject->fetchRow($tableProject->select()->where('project_id = ?', $this->getParam('contentid'))
                                                            ->where('status = ?', Application_Model_Project::PROJECT_ACTIVE));
        }

        if (!$project) {
            //$this->_sendErrorResponse(101, 'content not found');
            header('Location: ' . $this->_config['icon']);
            exit;
        }

        $previewPicSize = array(
            'width'  => 100,
            'height' => 100
        );

        if (!empty($this->_params['size'])
            && strtolower($this->_params['size']) == 'medium') {
            $previewPicSize = array(
                'width'  => 770,
                'height' => 540
            );
        }

        $viewHelperImage = new Application_View_Helper_Image();
        $previewPicUri = $viewHelperImage->Image($project->image_small, $previewPicSize);

        header('Location: ' . $previewPicUri);
        exit;
    }

    public function commentsAction()
    {
        if ($this->_format == 'json') {
            $response = array(
                'status'     => 'ok',
                'statuscode' => 100,
                'message'    => '',
                'data'       => array()
            );
        } else {
            $response = array(
                'meta' => array(
                    'status'     => array('@text' => 'ok'),
                    'statuscode' => array('@text' => 100),
                    'message'    => array('@text' => ''),
                ),
                'data' => array()
            );
        }

        $commentType = (int)$this->getParam('comment_type', -1);
        if ($commentType != self::COMMENT_TYPE_CONTENT) {
            $this->_sendResponse($response, $this->_format);
        }

        $contentId = (int)$this->getParam('content_id', null);
        if (empty($contentId)) {
            $this->_sendResponse($response, $this->_format);
        }

        $page = (int)$this->getParam('page', 0) + 1;
        $pagesize = (int)$this->getParam('pagesize', 10);

        /** @var Zend_Cache_Core $cache */
        $cache = Zend_Registry::get('cache');
        $cacheName = 'api_fetch_comments_' . md5("{$commentType}, {$contentId}");

        if (false === ($comments = $cache->load($cacheName))) {
            $modelComments = new Application_Model_ProjectComments();
            $comments = $modelComments->getCommentsHierarchic($contentId);
            $cache->save($comments, $cacheName, array(), 1800);
        }

        if ($comments->count() == 0) {
            $this->_sendResponse($response, $this->_format);
        }

        $comments->setCurrentPageNumber($page);
        $comments->setItemCountPerPage($pagesize);

        if ($page > $comments->getPages()->pageCount) {
            $this->_sendResponse($response, $this->_format);
        }

        $response['data'] = array('comment' => $this->_buildCommentList($comments->getCurrentItems()));

        $this->_sendResponse($response, $this->_format);
    }

    /**
     * @param Traversable $currentItems
     *
     * @return array
     */
    protected function _buildCommentList($currentItems)
    {
        $commentList = array();
        foreach ($currentItems as $current_item) {
            if ($this->_format == 'json') {
                $comment = array(
                    'id'         => $current_item['comment_id'],
                    'subject'    => '',
                    'text'       => Application_Model_HtmlPurify::purify($current_item['comment_text']),
                    'childcount' => $current_item['childcount'],
                    'user'       => $current_item['username'],
                    'date'       => date('c', strtotime($current_item['comment_created_at'])),
                    'score'      => 0
                );
                if ($current_item['childcount'] > 0) {
                    $comment['children'] = $this->_buildCommentList($current_item['children']);
                }
            } else {
                $comment = array(
                    'id'         => array('@text' => $current_item['comment_id']),
                    'subject'    => array('@text' => ''),
                    'text'       => array('@text' => Application_Model_HtmlPurify::purify($current_item['comment_text'])),
                    'childcount' => array('@text' => $current_item['childcount']),
                    'user'       => array('@text' => $current_item['username']),
                    'date'       => array('@text' => date('c', strtotime($current_item['comment_created_at']))),
                    'score'      => array('@text' => 0)
                );
                if ($current_item['childcount'] > 0) {
                    $comment['children'] = $this->_buildCommentList($current_item['children']);
                }
            }
            $commentList[] = $comment;
        }

        return $commentList;
    }

    public function voteAction()
    {
        $this->_sendErrorResponse(405, "method not allowed");
    }

}
