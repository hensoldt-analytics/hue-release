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
<%!
from desktop.views import commonheader, commonfooter
%>
<%namespace name="layout" file="layout.mako" />
<%namespace name="util" file="util.mako" />
<%namespace name="comps" file="hcatalog_components.mako" />
${commonheader("HCatalog: Query Results", "hcatalog", user, "100px")}
${layout.menubar(section='tables')}

<div class="container-fluid">
	<h1>HCatalog: Query Results: ${util.render_query_context(query_context)}</h1>
	<div class="row-fluid">
		<div class="span3">
			<div class="well sidebar-nav">
				<ul class="nav nav-list">
					% if download_urls:
					<li class="nav-header">Downloads</li>
					<li><a target="_blank" href="${download_urls["csv"]}">Download as CSV</a></li>
					<li><a target="_blank" href="${download_urls["xls"]}">Download as XLS</a></li>
					% endif
					%if can_save:
					<li><a data-toggle="modal" href="#saveAs">Save</a></li>
					% endif
					<%
			          n_jobs = hadoop_jobs and len(hadoop_jobs) or 0
			          mr_jobs = (n_jobs == 1) and "MR Job" or "MR Jobs"
			        %>
				 	% if n_jobs > 0:
						<li class="nav-header">${mr_jobs} (${n_jobs})</li>

						% for jobid in hadoop_jobs:
						<li><a href="${url("jobbrowser.views.single_job", jobid=jobid)}">${jobid.replace("job_", "")}</a></li>
						% endfor
					% else:
						<li class="nav-header">${mr_jobs}</li>
						<li>No Hadoop jobs were launched in running this query.</li>
					% endif
				</ul>
			</div>
		</div>
		<div class="span9">
				<ul class="nav nav-tabs">
					<li class="active"><a href="#results" data-toggle="tab">
		  			%if error:
			            Error
					%else:
						Results
					%endif
					</a></li>
					<li><a href="#query" data-toggle="tab">Query</a></li>
					<li><a href="#log" data-toggle="tab">Log</a></li>
				</ul>

				<div class="tab-content">
					<div class="active tab-pane" id="results">
					% if error:
		            <div class="alert alert-error">
		              <h3>Error!</h3>
		              <pre>${error_message | h}</pre>
		            </div>
          			% else:
		            % if expected_first_row != start_row:
		              <div class="alert"><strong>Warning:</strong> Page offset may have incremented since last view.</div>
		            % endif
            		<table class="table table-striped table-condensed resultTable" cellpadding="0" cellspacing="0">
		              <thead>
		                <tr>
		                  <th>&nbsp;</th>
		                  % for col in columns:
		                    <th>${col}</th>
		                  % endfor
		                </tr>
		              </thead>
		              <tbody>
		                % for i, row in enumerate(results):
		                <tr>
		                  <td>${start_row + i}</td>
		                  % for item in row:
		                    <td>${ item }</td>
		                  % endfor
		                </tr>
		                % endfor
		              </tbody>
		            </table>
					<div class="pagination pull-right">
				    	<ul>
							% if start_row != 0:
				            <li><a href="${ url('hcatalog.views.view_results', query.id, 0) }" title="Back to first row">Back to first row</a></li>
							% else:
							<li class="active"><a href="#" title="Back to first row">Back to first row</a></li>
				            % endif
							% if has_more:
				    		<li><a href="${ url('hcatalog.views.view_results', query.id, next_row) }" title="Next page">Next page &rarr;</a></li>
							% endif
				    	</ul>
				    </div>
		          % endif
				</div>
				<div class="tab-pane" id="query">
						<pre>${query.query | h}</pre>
				</div>
				<div class="tab-pane" id="log">
					<pre>${log | h}</pre>
				</div>
			</div>

		</div>
	</div>
</div>

%if can_save:
<div id="saveAs" class="modal hide fade">
	<form id="saveForm" action="${url('hcatalog.views.save_results', query.id) }" method="POST" class="form form-inline form-padding-fix">
	    <div class="modal-header">
	        <a href="#" class="close" data-dismiss="modal">&times;</a>
	        <h3>Save Query Results</h3>
	    </div>
	    <div class="modal-body">
			<label class="radio">
				<input id="id_save_target_0" type="radio" name="save_target" value="to a new table" checked="checked"/>
				&nbsp;In a new table
			</label>
			${comps.field(save_form['target_table'], notitle=True, placeholder="Table Name")}
			<br/>
			<label class="radio">
				<input id="id_save_target_1" type="radio" name="save_target" value="to HDFS directory">
				&nbsp;In an HDFS directory
			</label>
			${comps.field(save_form['target_dir'], notitle=True, hidden=True, placeholder="Results location", klass="pathChooser")}
			<br/>
			<br/>
			<div id="fileChooserModal" class="smallModal well hide">
				<a href="#" class="close" data-dismiss="modal">&times;</a>
			</div>
	    </div>
	    <div class="modal-footer">
			<div id="fieldRequired" class="hide" style="position: absolute; left: 10;">
				<span class="label label-important">Sorry, name is required.</span>
	        </div>
	        <input type="submit" class="btn primary" value="Save" name="save" />
			<button class="btn" data-dismiss="modal">Cancel</button>
	    </div>
    </form>
</div>
%endif


<script type="text/javascript" charset="utf-8">
	$(document).ready(function(){
		$(".resultTable").dataTable({
			"bPaginate": false,
		    "bLengthChange": false,
			"bInfo": false
		});
		$(".dataTables_wrapper").css("min-height","0");
		$(".dataTables_filter").hide();
		$("input[name='save_target']").change(function(){
			$("#fieldRequired").addClass("hide");
			$("input[name='target_dir']").removeClass("fieldError");
			$("input[name='target_table']").removeClass("fieldError");
			if ($(this).val().indexOf("HDFS")>-1){
				$("input[name='target_table']").addClass("hide");
				$("input[name='target_dir']").removeClass("hide");
			}
			else {
				$("input[name='target_table']").removeClass("hide");
				$("input[name='target_dir']").addClass("hide");
			}
		});

		$("#saveForm").submit(function(){
			if ($("input[name='save_target']:checked").val().indexOf("HDFS")>-1){
				if ($.trim($("input[name='target_dir']").val()) == ""){
					$("#fieldRequired").removeClass("hide");
					$("input[name='target_dir']").addClass("fieldError");
					return false;
				}
			}
			else {
				if ($.trim($("input[name='target_table']").val()) == ""){
					$("#fieldRequired").removeClass("hide");
					$("input[name='target_table']").addClass("fieldError");
					return false;
				}
			}
			return true;
		});

		$(".pathChooser").click(function(){
			var self = this;
			$("#fileChooserModal").jHueFileChooser({
				onFileChoose: function(filePath) {
					$(self).val(filePath);
				},
				onFolderChange: function(folderPath){
					$(self).val(folderPath);
				},
				createFolder: false,
				uploadFile: false
			});
			$("#fileChooserModal").slideDown();
		});
	});
</script>

${commonfooter()}
