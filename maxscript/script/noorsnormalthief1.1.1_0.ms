--NoorsNormalThief 1.1
--by JB "Noors" Sarrazin
--Transfer normals from a source object to a target object vertex normals
--Works with any type of geometry
--Adds an Edit Normals modifier

--v1.1.1 2019-01-18
--fixed : reset Xform source copy, so projection acts correctly when source object has transforms.

--v1.1 2019-01-02 :
--+ transfer normals only on selected faces. If no face selected, transfer on all faces
--+ get normal from closest point instead of closest vert
--+ removed windows messages preventing viewport to refresh in case of script crash
--+ tweaked UI
--+ clean code

--v1 2014-08-21 : initial release

-- Based on : 
--SlideNormalThief By Slide Ltd 2010-06-26 (contact@slidelondon.com)
--Normal Thief 1.0 By Mauricio B. G. (mbg@southlogic.com)

macroScript NoorsNormalThief
category:"Noors"
buttontext:"NNT"
toolTip:"NoorsNormalThief"

(

fn TransferNormals sObj tObj = 
(
	start = timestamp()
	--get selected faces using copy instead of snapshot to keep poly :[
	selFaces = #{}
	disableRefMsgs()
	tObjCopy = copy tObj
	if (classof tObjCopy != editable_poly) and (classof tObjCopy != editable_mesh) do converttopoly tObjCopy
	selFaces = getFaceSelection tObjCopy
	--if no faces selected, select all
	if selFaces.numberset == 0 do selFaces = #{1..tObjCopy.numfaces}	
	delete tObjCopy
	enableRefMsgs()
	
	--snapshot/xform the source object so we don't mess with it
	sMesh = snapshotasmesh sObj
	sObjSnap = editable_mesh()
	sObjSnap.mesh = sMesh

	mod_tObj = Edit_Normals ()
	mod_tObj.displayLength = 1

	mod_sObjSnap = Edit_Normals ()
	mod_sObjSnap.displayLength = 0

	addmodifier tObj mod_tObj
	addmodifier sObjSnap mod_sObjSnap

	--cache
	_getNormalID = mod_sObjSnap.GetNormalID
	_getNormal = mod_sObjSnap.GetNormal

	_getFaceDegree = mod_tObj.GetFaceDegree
	_getVertexID = mod_tObj.GetVertexID
	_getVertex = mod_tObj.GetVertex
	_getNormalIDt = mod_tObj.getNormalID
	_ConvertVertexSelection = mod_tObj.ConvertVertexSelection
	_setSelection = mod_tObj.SetSelection
	_makeExplicit = mod_tObj.MakeExplicit
	_setNormal = mod_tObj.Setnormal

	nID_Arr = #()
	nVal_Arr = #()
	hitFaceBary_Arr = #()
	faceID_Arr = #()
	done = #()
	
	mpi = MeshProjIntersect()
	mpi.setNode sObjSnap
	mpi.build()
	
	--! editNormals has to be the current selection, with modify panel on !
	select tObj --should be already selected but just in case
	tObjTransform = tObj.transform
	
	max modify mode

	--for each selected face...
	for f in selFaces do
	(
		corners = _getFaceDegree f 
		--for each face corner...
		for c=1 to corners do
		(
			--get vertex ID
			v = _getVertexID f c
			if finditem done v == 0 do
			(
				try
				(
					--get vert closest face barycenter in source mesh
					--get vert normal ID
					pos = (_getVertex v)*tObjTransform --world pos
					mpi.closestFace pos doubleSided:true
					hitFace = mpi.GetHitFace()+1 --zero based
					bary = mpi.GetHitBary()
					nID = _getNormalIDt f c
					--? should we break the id if only 1 smoothing group ?
					append hitFaceBary_Arr #(hitFace,bary)
					append nID_Arr  nID
				)
				catch (format "Error on vert:%\n" v)
				sharedNorm = #{}
				_ConvertVertexSelection #{v} sharedNorm
				--if the vertex has only 1 normal, we're done with it
				--? could be more optimized ?
				if sharedNorm.numberset == 1 do append done v
			)
		)
	)

	--get normal from source faces barycenters
	select sObjSnap
	--for each hitFace...
	for faceBary in hitFaceBary_Arr do
	(
		f = faceBary[1]
		bary = faceBary[2]
		--get its vertex normals
		n1 = _getNormal (_getNormalID f 1)
		n2 = _getNormal (_getNormalID f 2)
		n3 = _getNormal (_getNormalID f 3)
		--get barycenter normal
		n= (bary.x*n1)+(bary.y*n2)+(bary.z*n3)
		append nVal_Arr n
	)

	--set normals on target object
	select tObj
	subobjectLevel = 1
	disableRefMsgs()
	for i=1 to nID_Arr.count do
	(
		nID = nID_Arr[i]
		n = nVal_Arr[i]
		_setSelection #{nID}
		_MakeExplicit()
		_setNormal nID n
	)
	enableRefMsgs()

	--clean
	mpi.Free()
	delete sObjSnap
	gc light:true

	select tObj
	format "Normals transfer took % seconds\n" ((timestamp()-start)/1000.0)
)

--UI
if NoorsNormalThief !=undefined do destroyDialog NoorsNormalThief
rollout NoorsNormalThief " NoorsNormalThief 1.1" width:146
(
	group "1.Steal normals from"
	(
		pickbutton pick_source "Source Object" width:120 align:#left
	)
	
	group "2.Select Target Obj/Faces"
	(
	)
	
	group "3.Steal"
	(
		button bt_steal "Steal !" width:120 align:#left
	)
	
	on pick_source picked obj do
	(
		if obj != undefined do pick_source.text = obj.name
	)
	
	on bt_steal pressed  do
	(	
		source = pick_source.object 
		target = (selection as array)[1]
		
		if (source != undefined) and (target != undefined) then 
		(
			if (superclassof source == geometryclass) and (superclassof target == geometryclass) then
			(
				format "Source: %\n" source
				format "Target: %\n" target
				TransferNormals source target
			)
			else(messageBox "Souce or Target are not valid geometry objects." title:"Oops !" )
		)
		else(messageBox "Please set a Source Object and select a Target Object ." title:"Oops !" )
	)
)
createDialog NoorsNormalThief style:#(#style_toolwindow, #style_sysmenu)
)
