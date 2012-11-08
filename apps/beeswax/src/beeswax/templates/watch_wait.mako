## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
%>
<%namespace name="layout" file="layout.mako" />
<%namespace name="util" file="util.mako" />
${commonheader(_('Waiting for query...'), "beeswax", user, "100px")}
${layout.menubar(section='query')}

<meta http-equiv="refresh" content="3;${url('beeswax.views.watch_query', query.id)}?${fwd_params}" />

<div class="container-fluid">
	<h1>${_('Waiting for query...')} ${util.render_query_context(query_context)}</h1>
	<div class="row-fluid">
		<div class="span3">
			<div class="well sidebar-nav">
				<ul class="nav nav-list">
					<%
			          n_jobs = hadoop_jobs and len(hadoop_jobs) or 0
			          mr_jobs = (n_jobs == 1) and _('MR Job') or _('MR Jobs')
			        %>
				 	% if n_jobs > 0:
						<li class="nav-header">${mr_jobs} (${n_jobs})</li>

						% for jobid in hadoop_jobs:
						<li><a href="${url("jobbrowser.views.single_job", jobid=jobid)}">${jobid.replace("job_", "")}</a></li>
						% endfor
					% else:
						<li class="nav-header">${mr_jobs}</li>
						<li>${_('No Hadoop jobs were launched in running this query.')}</li>
					% endif
				</ul>
			</div>
		</div>
		<div class="span9">
			<ul class="nav nav-tabs">
				<li class="active"><a href="#log" data-toggle="tab">${_('Log')}</a></li>
				<li><a href="#query" data-toggle="tab">${_('Query')}</a></li>
			</ul>

		   	<div class="tab-content">
				<div class="active tab-pane" id="log">
					<pre>${log | h}</pre>
				</div>
				<div class="tab-pane" id="query">
					<pre>${query.query | h}</pre>
				</div>
			</div>
		</div>
	</div>
</div>



${commonfooter(messages)}
