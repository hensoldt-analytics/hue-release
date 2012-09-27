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
<%namespace name="comps" file="hcatalog_components.mako" />
<%namespace name="util" file="util.mako" />
${commonheader("HCatalog: Create table from file", "hcatalog", "100px")}
${layout.menubar(section='create table')}

<div class="container-fluid">
	<h1>Create a new table from file</h1>
	<div class="row-fluid">
		<div class="span3">
			<div class="well sidebar-nav">
				<ul class="nav nav-list">
					<li class="nav-header">Actions</li>
					<li><a href="${ url('hcatalog.create_table.import_wizard')}">Create a new table from file</a></li>
					<li><a href="${ url('hcatalog.create_table.create_table')}">Create a new table manually</a></li>
				</ul>
			</div>
		</div>
		<div class="span9">
			<ul class="nav nav-pills">
			  <li><a href="${ url('hcatalog.create_table.import_wizard') }">Step 1: Choose File</a></li>
			  <li class="active"><a href="#">Step 2: Choose Delimiter</a></li>
			  <li><a href="#">Step 3: Define Columns</a></li>
			</ul>
			<br/>
			<form id="delimiterForm" action="${action}" method="POST">
				<div class="hidden">
					${util.render_form(file_form)}
					${comps.field(delim_form['file_type'])}
				</div>
				<fieldset>
					<legend>Choose A Delimiter</legend>
					<div class="clearfix">
						${comps.label(delim_form["delimiter"])}
						<div class="input">
							${comps.field(delim_form["delimiter"], render_default=True, attrs=dict(
								klass=""
							))}
							% if initial:
								<span class="help-inline">
									HCatalog has determined that this file is delimited by ${delim_readable}.
								</span>
							% endif
							<span class="help-block">
							Enter the column delimiter.  Must be a single character.  Use syntax like "\001" or "\t" for special characters.
							</span>
						</div>
					</div>
				</fieldset>
				<div class="actions">
					<input id="submit_preview" class="btn" type="submit" value="Preview" name="submit_preview"/>
					<input class="btn primary" type="submit" name="submit_delim" value="Select this delimiter" />
				</div>
			</form>
			<br/>
			<ul class="nav nav-tabs">
				<li class="active"><a href="#tablePreview" data-toggle="tab">Table preview</a></li>
			</ul>
			<div class="tab-content">
				<div class="active tab-pane" id="tablePreview">
					<table class="table table-striped table-condensed">
				      <thead>
				        <tr>
				          % for i in range(n_cols):
				            <th>col_${i+1}</th>
				          % endfor
				        </tr>
				      </thead>
				      <tbody>
				        % for row in fields_list:
				          <tr>
				            % for val in row:
				            <td>${val}</td>
				            % endfor
				          </tr>
				        % endfor
				      </tbody>
				    </table>
				</div>
			</div>
		</div>
	</div>
</div>


<script type="text/javascript" charset="utf-8">
	$(document).ready(function(){
		$("#id_delimiter_1").css("margin-left","4px").attr("placeholder","Please write here your delimiter").hide();
		$("#id_delimiter_0").change(function(){
			if ($(this).val() == "__other__"){
				$("#id_delimiter_1").show();
			}
			else {
				$("#id_delimiter_1").hide();
				$("#submit_preview").click();
			}
		});
	});
</script>

${commonfooter()}
