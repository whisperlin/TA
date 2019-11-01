rollout Dialog0 "title" width:162 height:300
(
	button btn1 "计算平均法线到颜色" pos:[22,27] width:200 height:37
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
				local _inf = verfaces[i]
				local totoalNormal = [0, 0, 0]
				--print ("ver " + _inf as string)  
				
				local FacesCount = _inf.count
				for _f in _inf do
				(
					local _normal = polyOp.getFaceNormal theNode _f
					totoalNormal = totoalNormal + _normal
				)
				totoalNormal = totoalNormal / FacesCount
				
				
				totoalNormal = normalize(totoalNormal)
				
				
				totoalNormal.y = totoalNormal.y
				totoalNormal.x = -totoalNormal.x
				totoalNormal.z = totoalNormal.z
				--print(totoalNormal)
				local norCol = totoalNormal * 255 * 0.5 + [128,128,128]
				
				local Col = norCol as color
				--print(Col)
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
cn_floater = newRolloutFloater "描边附属工具" 400 100
addRollout Dialog0 cn_floater

--createDialog Dialog0 300 600

