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
${commonheader("HCatalog: Create table from file", "hcatalog", user, "100px")}
${layout.menubar(section='tables')}

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
		  <li><a href="${ url('hcatalog.create_table.import_wizard') }">Step 2: Choose Delimiter</a></li>
		  <li class="active"><a href="#">Step 3: Define Columns</a></li>
		</ul>
		<br/>
		<form action="${action}" method="POST" class="form-stacked">
			<div class="hidden">
				${util.render_form(file_form)}
		        ${util.render_form(delim_form)}
		        ${unicode(column_formset.management_form) | n}
			</div>
			<%
		        n_rows = len(fields_list)
		        if n_rows > 2: n_rows = 2
		      %>
			<fieldset>
				<legend>Define your columns</legend>
				<div class="clearfix">

					<div class="input">
						<table class="table table-striped">
							<tr>
								<td>&nbsp;</td>
								% for form in column_formset.forms:
				                    <td>
										${comps.label(form["column_name"])}
										${comps.field(form["column_name"],
											render_default=False,
											attrs=dict(
												placeholder="Column name"
											)
										)}
										<br/><br/>
										${comps.label(form["column_type"])}
										${comps.field(form["column_type"],
											render_default=True
										)}
										${unicode(form["_exists"]) | n}
				                    </td>
				                  %endfor
							</tr>
							% for i, row in enumerate(fields_list[:n_rows]):
			                  <tr>
			                    <td><em>Row #${i + 1}</em></td>
			                    % for val in row:
			                      <td>${val}</td>
			                    % endfor
			                  </tr>
			                % endfor
						</table>

					</div>
				</div>
			</fieldset>
			<div class="actions">
				<input class="btn primary" type="submit" name="submit_create" value="Create Table" />
			</div>
		</form>
		</div>
	</div>
</div>


${commonfooter()}
