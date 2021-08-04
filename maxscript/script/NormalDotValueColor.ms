
rollout Dialog0 "title" width:162 height:300
(
	button btn1 "计算平均锐度值到颜色r" pos:[22,27] width:200 height:37
	on btn1 pressed  do
	(
		
		if  selection.count > 0 then
		(
			local theNode = selection[1]
			convertto theNode editable_poly
			local verNum = theNode.verts.count
 
			--print("verNum : " +  verNum as string)
			local verfaces = #()
			for i = 1 to  theNode.verts.count do
			(
				append verfaces #()
			)
			for i = 1 to theNode.faces.count do
			(
				local vs = polyOp.getFaceVerts theNode i
				--print ("face "+i as string +  vs as string)
				for _v in  vs do
				(
					append verfaces[ _v] i
				)
					
			)
			for i = 1 to verfaces.count do
			(
				local faces = verfaces[i]
				
				local _count = 0
				local _total = 0
				for i = 1 to  faces.count-1 do
				(
					for j = i to  faces.count-1 do
					(
						local _normal = polyOp.getFaceNormal theNode faces[j] 
						local _normal1 = polyOp.getFaceNormal theNode faces[j+1] 
						local _d = dot _normal _normal1
						_d = _d+1
						_d = _d*0.5
						_total = _total + _d
						_count = _count + 1
					)
				)
				if _count > 0 then
				(
					_total = _total/_count
				)
				else
				(
					_total = 1
				)
				--print(_total)
				_total = _total *255
				local norCol =  [_total,0,0]
				local Col = norCol as color
				local verlist = #{i}
				polyOp.setVertColor theNode 0 verlist Col
			 
			)
			
		)
		else
		(
			messagebox("没有选择物体")
		)
		
		 

	)
	 
)

if cn_floater != undefined then CloseRolloutFloater cn_floater
cn_floater = newRolloutFloater "描边附属工具(统计平均面朝向)" 400 100
addRollout Dialog0 cn_floater

--createDialog Dialog0 300 600

