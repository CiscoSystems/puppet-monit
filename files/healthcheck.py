# Copyright (c) 2010-2012 OpenStack, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os

from webob import Response

from keystone.common import wsgi
from keystone.common import logging
from keystone.common import sql

LOG = logging.getLogger(__name__)


class HealthCheckMiddleware(wsgi.Middleware):
    """
    Healthcheck middleware used for monitoring.

    If the path is /healthcheck, it will respond with "OK" in the body
    """
    def __init__(self, application):
        self.application = application
        self.session = sql.Base().get_engine()
        
    def db_check(self):
        try:
            sql_str = ""
            
            LOG.debug("engine name = %s" % self.session.name)
            
            if self.session.name == 'mysql':
                sql_str = "select now()"
            elif self.session.name == 'sqlite':
                sql_str = "select date('now')"
                
            LOG.debug("sql_str = %s" % sql_str)
            ret = self.session.execute(sql_str).fetchall()
            LOG.debug("ret = %s" % ret)
            return 0
        except Exception as e:
            LOG.exception(e)
            return -1

    def __check_manual_failover__(self):
        """
        Check the manual failover flag on local disk:
          1. If the file "/etc/keystone/.manualfailover/.failover" exists, return 1, the response status is "420 manual_failover";
          2. if the file "/etc/keystone/.manualfailover/.failover" does not exist, return 0,  needs to return "200 OK";
        """
        check_file = "/etc/keystone/.manualfailover/.failover"
        if os.path.exists(check_file) and os.path.isfile(check_file):
            return 1
        else:
            return 0
    
    def GET(self, req):
        """Returns a 200 response with "OK" in the body."""
        body="OK"
        status = "200 OK"
        
        if self.__check_manual_failover__() == 1:
            body = "MANUAL FAILOVER"
            status = "420 manual_failover"
        elif self.db_check() == -1:
            body = "DATABASE FAILED"
            status = "419 db_fail"

        return Response(request=req, body=body, status=status, content_type="text/plain")
    
    def process_request(self, request):
        LOG.debug('path = %r' % request.path)
        if request.path == '/healthcheck':
            return self.GET(request)

if __name__ == '__main__':
    db_checker = sql.Base()
    engine = db_checker.get_engine()
    print "Engine = %r" % engine
    print "Driver = %s, name = %s" % (engine.driver, engine.name)
    ret = engine.execute("select date('now')").fetchall()
    print "Date : %s" % ret
