<?php
/**
 *
 *   ocs-apiserver
 *
 *   Copyright 2016 by pling GmbH.
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
 */

class ErrorController extends Zend_Controller_Action
{

    public function errorAction()
    {
        $errors = $this->_getParam('error_handler');
        
        if (!$errors) {
            $message = 'You have reached the error page';
            return;
        }
        
        switch ($errors->type) {
            case Zend_Controller_Plugin_ErrorHandler::EXCEPTION_NO_ROUTE:
            case Zend_Controller_Plugin_ErrorHandler::EXCEPTION_NO_CONTROLLER:
            case Zend_Controller_Plugin_ErrorHandler::EXCEPTION_NO_ACTION:
                // 404 error -- controller or action not found
                $this->getResponse()->setHttpResponseCode(404);
                $priority = Zend_Log::NOTICE;
                $message = 'Page not found';
                break;
            default:
                // application error
                $this->getResponse()->setHttpResponseCode(500);
                $priority = Zend_Log::CRIT;
                $message = 'Application error';
                break;
        }
        
        // Log exception, if logger available
        if ($log = $this->getLog()) {
            $log->log($message, $priority, $errors->exception);
            $log->crit($errors->exception);
            $log->log('Request Parameters', $priority, $errors->request->getParams());
            $log->crit(print_r($errors->request->getParams(), true));
        }
        
        // conditionally display exceptions
        if ($this->getInvokeArg('displayExceptions') == true) {
            $exception = $errors->exception;
        }
        
        $request   = $errors->request;

        $this->getResponse()->setHttpResponseCode(500);
        $this->getResponse()->setBody(json_encode(array($message,$errors)));
    }

    /**
     * @return Zend_Log
     * @throws Zend_Exception
     */
    public function getLog()
    {
        //$bootstrap = $this->getInvokeArg('bootstrap');
        //if (!$bootstrap->hasResource('Log')) {
        //    return false;
        //}
        //$log = $bootstrap->getResource('Log');
        //return $log;
        return Zend_Registry::get('logger');
    }


}

