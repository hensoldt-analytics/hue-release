## Licensed to the Apache Software Foundation (ASF) under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  The ASF licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing,
## software distributed under the License is distributed on an
## "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
## KIND, either express or implied.  See the License for the
## specific language governing permissions and limitations
## under the License.
##
##
## no spaces in this method please; we're declaring a CSS class, and ART uses this value for stuff, and it splits on spaces, and
## multiple spaces and line breaks cause issues
<%!
from django.utils.translation import ugettext as _

def is_selected(section, matcher):
  if section == matcher:
    return "active"
  else:
    return ""
%>

<%def name="menubar(section='tables')">
<div class="subnav subnav-fixed">
	<div class="container-fluid">
		<ul class="nav nav-pills">
            <li class="${is_selected(section, 'databases')}"><a href="${ url(app_name + ':show_databases')}">${_('Databases')}</a></li>
		    <li class="${is_selected(section, 'tables')}"><a href="${ url(app_name + ':show_tables')}">${_('Tables')}</a></li>
		</ul>
	</div>
</div>
</%def>

 

