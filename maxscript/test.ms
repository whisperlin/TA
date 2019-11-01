rollout Dialog0 "title" width:162 height:300
(
	button btn1 "Button" pos:[22,27] width:84 height:37
	pickButton btn2 "PickButton" pos:[22,84] width:84 height:36
	on btn1 pressed  do
	(
		
		if  selection.count > 0 then
		(
			local theNode = selection[1]
			convertto theNode editable_poly
			local verNum = theNode.verts.count
 
			print("verNum : " +  verNum as string)
			local verfaces = #()
			for i = 1 to  theNode.verts.count do
			(
				append verfaces #()
			)
			for i = 1 to theNode.faces.count do
			(
				local vs = polyOp.getFaceVerts theNode i
				print ("face "+i as string +  vs as string)
				for _v in  vs do
				(
					append verfaces[ _v] i
				)
					
			)
			for i = 1 to verfaces.count do
			(
				local _inf = verfaces[i]
				local totoalNormal = [0, 0, 0]
				print ("ver " + _inf as string)  
				
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
				print(totoalNormal)
				local norCol = totoalNormal * 255 * 0.5 + [128,128,128]
				
				local Col = norCol as color
				print(Col)
				local verlist = #{i}
				polyOp.setVertColor theNode 0 verlist Col
			 
			)
			
		)
		else
		(
			messagebox("no obj select")
		)
		
		--local faceNum = theNode.faces.count
		
		--local iModIndex = theNode.modifiers.count
		--polyOp.setFaceSelection theNode #{1..faceNum} 
		--local baFaceSelection = polyOp.getFaceSelection theEditObj
		 
		--print theNode

	)
	on btn2 picked obj do
   (
		print obj.name
		if (Filters.Is_EditPoly()) then
		(
			if (getCommandPanelTaskMode() != #modify) do
				setCommandPanelTaskMode #modify
			local theNode = obj
			local iModIndex = theNode.modifiers.count
			print iModIndex
			print theNode
		)
		else
		(
			messagebox( "no Is_EditPoly")
		)
	)
)
createDialog Dialog0 300 600