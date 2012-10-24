<%def name="my_scripts(pig_scripts)">
<h2>My scripts</h2>
<ul class="nav nav-list">
  % for v in pig_scripts:
  <li>
    <p>
      <a href="${url('pig.views.delete', v.id)}">
        <img src="/pig/static/art/delete.gif" alt="Delete" height="12" width="12">
      </a>
      <a href="${url('pig.views.script_clone', v.id)}">
	<img src="/pig/static/art/clone.png" alt="Delete" height="14" width="14">
      </a>
      <a href="${url('pig.views.index', obj_id=v.id)}">
	% if v.title: 
	${v.title}
        % else:
        no title
        % endif
      </a>&nbsp;&nbsp;
    </p>
  </li>
  % endfor
</ul>
<a class="btn" href="${url('root_pig')}">New script</a>
</%def>

<%def name="udfs(udfs)">
  % for udf in udfs:
<li>
  <a class="udf_register" href="#" value="${udf.file_name}">${udf.file_name}</a>
</li>
% endfor
</%def>
