--常用公用函数定义
fn isUsualObj obj = (  --是否为常规物体
	isValidObj obj and canConvertTo obj Editable_Poly and classof obj.baseobject !=boneGeometry and classof obj.baseobject!=Biped_Object 
)

-- 这个插件模拟了maya中的一个属性转移的功能，但添加了一个顶点属性转移的功能，作用就是将第一个拾取按钮拾取到的物体A的 顶点法线 或 顶点位置 趋向于 第二个拾取按钮拾取到的物体B
-- 使A的顶点的法线或位置 改变到与之最近的 B的顶点的 法线或位置，其中法线的功能主要用在树冠的法线转换上

rollout rt_attriTrans "属性转换" width:220 height:251 (
	group "转换类型" (
		radioButtons rbn_TransType ""  labels:#("法线","顶点") width:200 default:1 columns:2 width:200
	)
	
	
	pickbutton pbn_main "拾取需要转换的物体" message:"拾取需要转换信息的组件" filter: isusualObj autoDisplay:on width:200
	pickbutton pbn_scnd "拾取参考物体" message:"拾取包围球" filter: isusualObj  autoDisplay:on width:200
	button btn_transfer "拾取后转换" width:200

	local normalArr = #()
	local posArr = #()
	local vcArr = #()
	
	on pbn_main picked obj do(
		pbn_main.caption = "需要转换的物体为: -> "+obj.name
	)
	
	on pbn_scnd picked obj do(
		pbn_scnd.caption = "参考物体（包围球）: -> "+obj.name
	)
	
	fn transferNormal mainobj scndobj =(
		scndVPosArr = #()
		mainVPosArr = #()
		for i=1 to scndobj.mesh.numverts do (
			vPos = meshop.getvert scndobj.mesh i + scndobj.pos
			append scndVPosArr vPos
		)
		
		for i=1 to mainobj.mesh.numverts do(
			vPos = meshop.getvert mainobj.mesh i + mainobj.pos
			append mainVPosArr vPos
		)
		mainVnormal = #()
		for i=1 to mainVposArr.count do(
			minDistVind = 1
			minDist = distance mainVposArr[i] scndVposArr[1]
			for j=2 to scndVposArr.count do(
				tempDist = distance mainVposArr[i] scndVposArr[j]
				if tempDist<minDist do (
					minDist = tempDist
					minDistVind = j
				)						
			)
			minDistVNormal = getNormal scndobj.mesh minDistVind
			append mainVnormal minDistVNormal
		)
		max modify mode --必须转到修改面板，否则修改器的设置不保证绝对生效
		addModifier mainobj (edit_Normals()) before:(mainobj.modifiers.count)
		modPanel.setCurrentObject mainobj.edit_Normals node:mainobj ui:on
		normalSel = #{}
		for vInd=1 to mainVnormal.count do( --mainVnormal的数量就是mainobj顶点的数量
			mainobj.edit_Normals.ConvertVertexSelection #{vInd} normalSel node:mainobj 
			vNormalArr = normalSel as array
			for ind in vNormalArr do(
				mainobj.Edit_Normals.SetNormalExplicit ind explicit:true node:mainobj
				mainobj.Edit_Normals.SetNormal ind mainVnormal[vInd] node:mainobj
			)
		)
		
		convertTo mainobj Editable_poly
		update mainobj.mesh
		update mainobj
	)
	
	fn transferVertex mainobj scndobj = (
		if scndobj==undefined or mainobj==undefined then return 0
		else (
			scndVerts = for i=1 to scndobj.numverts collect i
			mainVerts = for i=1 to mainobj.numverts collect i
			sindArr = #()
			mposArr = #()
			for sind in scndVerts do(       --遍历主索引
				distanceArr =#()
				_distanceArr=#()
				spos = polyOp.getVert scndobj sind
				for mind in mainVerts do(      --遍历次索引
					mpos = polyOp.getVert mainobj mind
					append distanceArr (distance spos mpos)
				)
				minDistance = amin distanceArr
				mind = mainVerts[findItem distanceArr minDistance]   --找到与当前主索引的点最近的次物体上的点的索引
				mpos = polyOp.getVert mainobj mind

				for _mind in  scndVerts do(     --再根据次物体上的该点找与之最近的主物体上的点的索引
					_mpos = polyOp.getVert scndobj _mind
					append _distanceArr (distance _mpos mpos)
				)
				minDistance = amin _distanceArr
				_mind = scndVerts[findItem _distanceArr minDistance] 
				if sind == _mind do (            --如果该点与主循环上的索引相同，则形成配对关系
					append mposArr spos   
					append sindArr mind
				)
			)
			for i = 1 to sindArr.count do(
				polyOp.setVert mainobj #{sindArr[i]} mposArr[i]
			)
		)
	)

	
	on btn_transfer pressed do(
		mainobj = pbn_main.object
		scndobj = pbn_scnd.object
		
		if mainobj == undefined or scndobj == undefined or rbn_TransType.state == 0  do return 0
		ResetXForm mainobj
		convertTo mainobj editable_poly 
		ResetXForm scndobj
		convertTo scndobj editable_poly 
		
		if rbn_TransType.state == 1 then ( --处理法线转移，不考虑堆栈
			transferNormal mainobj scndobj
		)
		else if rbn_TransType.state == 2 then ( --处理位置吸附
			transferVertex mainobj scndobj
		)
	)
	
	button btn3 "更多工具" pos:[44,165] width:120 height:32
	hyperlink hl "微元素论坛" address:"http://www.element3ds.com" align:#center
	groupBox grp1 "开发者" pos:[8,143] width:205 height:91
	
	on btn3 pressed do
	(
		(DotNetClass "System.Diagnostics.Process").Start("http://www.element3ds.com/forum.php?mod=forumdisplay&fid=104")
	)
)

createDialog rt_attriTrans style:#(#style_toolwindow,#style_sysmenu )

