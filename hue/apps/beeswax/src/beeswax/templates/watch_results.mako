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
from desktop.lib.i18n import smart_unicode
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
%>

<%namespace name="layout" file="layout.mako" />
<%namespace name="util" file="util.mako" />
<%namespace name="comps" file="beeswax_components.mako" />

${ commonheader(_('Query Results'), app_name, user, '100px') | n,unicode }
${layout.menubar(section='query')}

<style>
  #collapse {
    float: right;
    cursor: pointer;
  }

  #expand {
    display: none;
    cursor: pointer;
    position: absolute;
    background-color: #01639C;
    padding: 3px;
    -webkit-border-top-right-radius: 5px;
    -webkit-border-bottom-right-radius: 5px;
    -moz-border-radius-topright: 5px;
    -moz-border-radius-bottomright: 5px;
    border-top-right-radius: 5px;
    border-bottom-right-radius: 5px;
    opacity: 0.5;
    left: -4px;
  }

  #expand:hover {
    opacity: 1;
    left: 0;
  }

  .resultTable td, .resultTable th {
    white-space: nowrap;
  }

  .noLeftMargin {
    margin-left: 0!important;
  }

  .ri_header {
    display: inline;
    font-size: 12px;
  }

</style>

<div class="container-fluid">
  <h1>${_('Query Results:')} ${ util.render_query_context(query_context) }</h1>
  <div id="expand"><i class="icon-chevron-right icon-white"></i></div>
    <div class="row-fluid">
        <div class="span3">
            <div class="well sidebar-nav">
        <a id="collapse" class="btn btn-small"><i class="icon-chevron-left" rel="tooltip" title="${_('Collapse this panel')}"></i></a>
                <ul class="nav nav-list">
                    % if download_urls:
                    <li class="nav-header">${_('Downloads')}</li>
                    <li><a target="_blank" href="${download_urls["csv"]}">${_('Download as CSV')}</a></li>
                    <li><a target="_blank" href="${download_urls["xlsx"]}">${_('Download as XLSX')}</a></li>
                    <%
                    from django.core.urlresolvers import reverse
                    export_results = None
                    try:
                      export_results = reverse(app_name + ':export_results', kwargs={'id': query.id})
                    except Exception:
                      pass
                    %>
                    % if export_results:
                    <li><a href="${export_results}">${_('Export to DB2')}</a></li>
                    % endif
                    % endif
                    %if can_save:
                    <li><a data-toggle="modal" href="#saveAs">${_('Save')}</a></li>
                    % endif

                    % if result_info and (result_info['size'] != 'unknown' or result_info['virtual_memory'] != 'unknown'):
                      <li class="nav-header">Results</li>

                      %if result_info['size'] != 'unknown':
                        <li><div class="ri_header">${_('Size: ')}</div>${result_info['size']}</li>
                      %endif

                      %if result_info['rows'] != 'unknown' and len(results)>0:
                        <li><div class="ri_header">${_('Rows: ')}</div>${result_info['rows']}</li>
                      %endif
                      %if result_info['total_time'] != 'unknown':
                        <li><div class="ri_header">${_('Total Time: ')}</div>${result_info['total_time']}</li>
                      %endif
                      %if result_info['query_time'] != 'unknown':
                        <li><div class="ri_header">${_('CPU Time: ')}</div>${result_info['query_time']}</li>
                      %endif
                      %if result_info['committed_memory'] != 'unknown':
                        <li><div class="ri_header">${_('Committed Memory: ')}</div>${result_info['committed_memory']}</li>
                      %endif
                      %if result_info['physical_memory'] not in ['unknown', None]:
                        <li><div class="ri_header">${_('Physical Memory: ')}</div>${result_info['physical_memory']}</li>
                      %endif
                      %if result_info['virtual_memory'] not in ['unknown', None]:
                        <li><div class="ri_header">${_('Virtual Memory: ')}</div>${result_info['virtual_memory']}</li>
                      %endif
                    %endif

                    % if app_name != 'impala':
                      <%
                        n_jobs = hadoop_jobs and len(hadoop_jobs) or 0
                        mr_jobs = (n_jobs == 1) and _('MR Job') or _('MR Jobs')
                      %>
                       % if n_jobs > 0:
                          <li class="nav-header">${mr_jobs} (${n_jobs})</li>
                          % for jobid in hadoop_jobs:
                              <li><a href="${url("jobbrowser.views.single_job", job=jobid.replace('application', 'job'))}">${ jobid.replace("application_", "") }</a></li>
                          % endfor
                      % endif
                    % endif
                </ul>
            </div>

          % if not query.is_finished() and query and query.design:
            <div id="multiStatementsQuery" class="alert">
              <button type="button" class="close" data-dismiss="alert">&times;</button>
              <strong>${_('Multi-statement query')}</strong></br>
              ${_('Hue stopped as one of your query contains some results.') }
              ${_('Click on') }
              <form action="${ url(app_name + ':watch_query', query.id) }?context=${ query.design.get_query_context() }" method="POST"> ${ csrf_token_field | n } 
                <input type="submit" value="${ _("next") }"/ class="btn btn-danger">
              </form>
              ${_('for continuing the execution of the remaining statements.') }
            </div>
          % endif

          <div id="jumpToColumnAlert" class="alert hide">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <strong>${_('Did you know?')}</strong>
            ${_('If the result contains a large number of columns, click a row to select a column to jump to.') }
            ${ _('As you type into the field, a drop-down list displays column names that match the string.')}
          </div>
        </div>

        <div class="span9">
      <ul class="nav nav-tabs">
        <li class="active"><a href="#results" data-toggle="tab">
            %if error:
                  ${_('Error')}
            %else:
                  ${_('Results')}
            %endif
        </a></li>
        <li><a href="#query" data-toggle="tab">${_('Query')}</a></li>
        <li><a href="#log" data-toggle="tab">${_('Log')}</a></li>
        % if not error:
        <li><a href="#columns" data-toggle="tab">${_('Columns')}</a></li>
        % endif
      </ul>

      <div class="tab-content">
        <div class="active tab-pane" id="results">
            % if error:
              <div class="alert alert-error">
                <h3>${_('Error!')}</h3>
                <pre>${ error_message }</pre>
                % if expired and query_context:
                    <div class="well">
                        ${ _('The query result has expired.') }
                        ${ _('You can rerun it from ') } ${ util.render_query_context(query_context) }
                    </div>
                % endif
              </div>
            % else:
            % if expected_first_row != start_row:
                <div class="alert"><strong>${_('Warning:')}</strong> ${_('Page offset may have incremented since last view.')}</div>
            % endif
            <table id="rs" class="table table-striped table-bordered table-condensed resultTable" cellpadding="0" cellspacing="0" data-tablescroller-min-height-disable="true" data-tablescroller-enforce-height="true">
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
              <tr id="tr_${ i }">
                <td onClick=selectText(&quot;tr_${i}&quot;)>${ start_row + i }</td>
                % for item in row:
                  <td>${ smart_unicode(item, errors='ignore') }</td>
                % endfor
              </tr>
              % endfor
            </tbody>
            </table>
            <div class="pagination pull-right">
              <ul>
              % if start_row != 0:
                      <li class="prev"><a title="${_('Beginning of List')}" href="${ url(app_name + ':view_results', query.id, 0) }${'?context=' + context_param or '' | n}">&larr; ${_('Beginning of List')}</a></li>
              % endif
              % if has_more and len(results) == 100:
                  <li><a title="${_('Next page')}" href= "${ url(app_name + ':view_results', query.id, next_row) }${'?context=' + context_param or '' | n }">${_('Next Page')} &rarr;</a></li>
              % endif
              </ul>
            </div>
            % endif
        </div>

        <div class="tab-pane" id="query">
          <pre>${ query.get_current_statement() }</pre>
        </div>

        <div class="tab-pane" id="log">
          <pre>${ log }</pre>
        </div>

        % if not error and download_urls.get("csv"):
        <div class="tab-pane" id="columns">
          <table id="cs" class="table table-striped table-bordered table-condensed resultTable" cellpadding="0" cellspacing="0">
            <thead>
              <tr><th>&nbsp;</th><th>${_('Name')}</th></tr>
            </thead>
            <tbody>
              % for i, col in enumerate(columns):
                <tr id="col_${i}"><td onClick=selectText(&quot;col_${i}&quot;)>${i+1}</td><td>${col}</td></tr>
              % endfor
            </tbody>
          </table>
        </div>
        % endif
      </div>

        </div>
    </div>
</div>

%if can_save:
## duplication from save_results.mako
<div id="saveAs" class="modal hide fade">
  <form id="saveForm" action="${url(app_name + ':save_results', query.id) }" method="POST"
        class="form form-inline form-padding-fix"> ${ csrf_token_field | n } 
    <div class="modal-header">
      <a href="#" class="close" data-dismiss="modal">&times;</a>
      <h3>${_('Save Query Results')}</h3>
    </div>
    <div class="modal-body">
      <label class="radio">
        <input id="id_save_target_0" type="radio" name="save_target" value="to a new table" checked="checked"/>
        &nbsp;${_('In a new table')}
      </label>
      ${comps.field(save_form['target_table'], notitle=True, placeholder=_('Table Name'))}
      <br/>
      <label class="radio">
        <input id="id_save_target_1" type="radio" name="save_target" value="to HDFS directory">
        &nbsp;${_('In an HDFS directory')}
      </label>
      ${comps.field(save_form['target_dir'], notitle=True, hidden=True, placeholder=_('Results location'), klass="pathChooser")}
      <br/>
      <br/>
      <div id="fileChooserModal" class="smallModal well hide">
        <a href="#" class="close" data-dismiss="modal">&times;</a>
      </div>
    </div>
    <div class="modal-footer">
      <div id="fieldRequired" class="hide" style="position: absolute; left: 10;">
        <span class="label label-important">${_('Sorry, name is required.')}</span>
      </div>
      <a class="btn" data-dismiss="modal">${_('Cancel')}</a>
      <a id="saveBtn" class="btn btn-primary">${_('Save')}</a>
      <input type="hidden" name="save" value="save"/>
    </div>
  </form>
</div>
%endif.resultTable



<script type="text/javascript" charset="utf-8">

%if go_to_column:
    var enable_popup = true;
% else:
    var enable_popup = false;
% endif

$(document).ready(function () {
  $(".resultTable").dataTable({
    "bPaginate": false,
    "bLengthChange": false,
    "bInfo": false,
    "oLanguage": {
        "sEmptyTable": "${_('No data available')}",
        "sZeroRecords": "${_('No matching records')}",
    },
    "fnDrawCallback": function( oSettings ) {
      if (enable_popup) {
        $(".resultTable").jHueTableExtender({
          hintElement: "#jumpToColumnAlert",
          fixedHeader: true,
          firstColumnTooltip: true
        });
      };
    }
  });
  $(".dataTables_wrapper").css("min-height", "0");
  $(".dataTables_filter").hide();
  $("input[name='save_target']").change(function () {
    $("#fieldRequired").addClass("hide");
    $("input[name='target_dir']").removeClass("fieldError");
    $("input[name='target_table']").removeClass("fieldError");
    if ($(this).val().indexOf("HDFS") > -1) {
      $("input[name='target_table']").addClass("hide");
      $("input[name='target_dir']").removeClass("hide");
      $(".fileChooserBtn").removeClass("hide");
    }
    else {
      $("input[name='target_table']").removeClass("hide");
      $("input[name='target_dir']").addClass("hide");
      $(".fileChooserBtn").addClass("hide");
    }
  });

  $("#saveBtn").click(function () {
    if ($("input[name='save_target']:checked").val().indexOf("HDFS") > -1) {
      if ($.trim($("input[name='target_dir']").val()) == "") {
        $("#fieldRequired").removeClass("hide");
        $("input[name='target_dir']").addClass("fieldError");
        return false;
      }
    }
    else {
      if ($.trim($("input[name='target_table']").val()) == "") {
        $("#fieldRequired").removeClass("hide");
        $("input[name='target_table']").addClass("fieldError");
        return false;
      }
    }
    $("#saveForm").submit();
  });


  $("input[name='target_dir']").after(getFileBrowseButton($("input[name='target_dir']")));

  function getFileBrowseButton(inputElement) {
    return $("<a>").addClass("btn").addClass("fileChooserBtn").addClass("hide").text("..").click(function (e) {
      e.preventDefault();
      $("#fileChooserModal").jHueFileChooser({
        onFolderChange:function (filePath) {
          inputElement.val(filePath);
        },
        onFolderChoose:function (filePath) {
          inputElement.val(filePath);
          $("#fileChooserModal").slideUp();
        },
        createFolder:false,
        uploadFile:false,
        selectFolder:true,
        initialPath:$.trim(inputElement.val())
      });
      $("#fileChooserModal").slideDown();
    });
  }

  $("#collapse").click(function () {
    $(".sidebar-nav").parent().css("margin-left", "-31%");
    $("#expand").show().css("top", $(".sidebar-nav i").position().top + "px");
    $(".sidebar-nav").parent().next().removeClass("span9").addClass("span12").addClass("noLeftMargin");
  });
  $("#expand").click(function () {
    $(this).hide();
    $(".sidebar-nav").parent().next().removeClass("span12").addClass("span9").removeClass("noLeftMargin");
    $(".sidebar-nav").parent().css("margin-left", "0");
  });

  resizeLogs();

  $(window).resize(function () {
    resizeLogs();
  });

  $("a[href='#log']").on("shown", function () {
    resizeLogs();
  });

  function resizeLogs() {
    $("#log pre").css("overflow", "auto").height($(window).height() - $("#log pre").position().top - 40);
  }

});

function selectText(element) {
    var text = document.getElementById(element);
    if ($.browser.msie) {
        var range = document.body.createTextRange();
        range.moveToElementText(text);
        range.select();
    } else if ($.browser.mozilla || $.browser.opera) {
        var selection = window.getSelection();
        var range = document.createRange();
        range.selectNodeContents(text);
        selection.removeAllRanges();
        selection.addRange(range);
    } else if ($.browser.safari) {
        var selection = window.getSelection();
        selection.setBaseAndExtent(text, 0, text, 1);
    }
}




var lastSelectedRow;
var trs = document.getElementById('rs').tBodies[0].getElementsByTagName('tr');

// disable text selection
document.onselectstart = function() {
    return false;
}

function RowClick(currenttr, lock) {
    if (window.event.ctrlKey) {
        toggleRow(currenttr);
    }
    
    if (window.event.button === 0) {
        if (!window.event.ctrlKey && !window.event.shiftKey) {
            clearAll();
            toggleRow(currenttr);
        }
    
        if (window.event.shiftKey) {
            selectRowsBetweenIndexes([lastSelectedRow.rowIndex, currenttr.rowIndex])
        }
    }
}

function toggleRow(row) {
    row.className = row.className == 'selected' ? '' : 'selected';
    lastSelectedRow = row;
}

function selectRowsBetweenIndexes(indexes) {
    indexes.sort(function(a, b) {
        return a - b;
    });

    for (var i = indexes[0]; i <= indexes[1]; i++) {
        trs[i-1].className = 'selected';
    }
}

function clearAll() {
    for (var i = 0; i < trs.length; i++) {
        trs[i].className = '';
    }
}
</script>

${ commonfooter(messages) | n,unicode }
