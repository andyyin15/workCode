local UILayerbase = import("...base/UILayerbase")
local ZBRecycleForever = class("ZBRecycleForever",UILayerbase)
local config_recycle_items=require "scripts/cnf/config_recycle_items"
local BaseTipsDialog = require "scripts/UI/component/BaseTipsDialog"

local equip_sort = {
	[1] = {id = 1, name = "头盔"},
	[2] = {id = 2, name = "戒指"},
	[3] = {id = 3, name = "手镯"},
	[4] = {id = 4, name = "项链"},
	[5] = {id = 5, name = "护腕"},
	[6] = {id = 6, name = "指环"},
	[7] = {id = 7, name = "腰带"},
	[8] = {id = 8, name = "鞋子"},
	[9] = {id = 9, name = "战刃"},
	[10] = {id = 10, name = "铠甲"},
}

function ZBRecycleForever:ctor()
	self.super.ctor(self)
	self.ZBItem_Info={}
	self.name= "ZBRecycleForever"
	self.csbfile = "equipRecycle/ZBRecycleForever.csb"
end

function ZBRecycleForever:create(_parent)
	self.super.create(self)
	self.parent = _parent
	self.baseLayer=self:seekNode("baseLayer")
	self.Panel=self:seekNode("Panel")
	self.tablePanel=self.Panel:getChildByName("tableBtn")
	self.Panel_nodeLayer=self.Panel:getChildByName("Panel_nodeLayer")
	self.listview=self.baseLayer:getChildByName("listview")

	self.lableview=self.baseLayer:getChildByName("lableview")
	self.lableview:setScrollBarEnabled(false)
	self.item_node=self.baseLayer:getChildByName("item_node")
	self.tiaozhan=self.baseLayer:getChildByName("tiaozhan")
	
	self.img_arrow=UIBuilder.createByWidget(self:seekNode("img_arrow"))
	self.openIndex = 1
	
	self.huishou_data={}
	self:bindEvent()
	self:_initViewData()
	self:_initView()
	self:SendMsg()

	return self
end

function ZBRecycleForever:bindEvent(  )
	local list={}
	list[1]={itemid=12108,count=1,bind=1}
	local itempages = ItemsPage:create(list, 0,0,1,#list,nil,nil,nil,true,nil,nil,nil,false,true,true)
	self.item_node:addChild(itempages)

	local openday =PrivateStateManager.getInstance():GetRDays()--开服天数
	local award_status = PrivateStateManager:getInstance():GetStateValue(2199) or 0
	if openday >= 8 and Utils:get_bit_by_position(award_status, 3) == 0 then
		local function tiaoZhuan()
			self.parent:_menuCallback(5) 
		end
		self.tiaozhan:addClickEventListener(tiaoZhuan)
		self.item_node:setVisible(true)
	else
		self.item_node:setVisible(false)
		self.tiaozhan:setVisible(false)
	end
end

function ZBRecycleForever:_initView()
	self.menu_index = 0
	self.lableview:removeAllChildren()
	self.btnList = {}
	if self.tableView then
		self.tableView:resetItemPool()
	else
		self.tableView = UIBuilder.CreateUITableView(0,0,740,380,self.Panel_nodeLayer,handler(self, self["updateCell"]),self.listview)
	end
	local function _tableViewEvent(tableView, eventType)
		if tableView._currPosY >= tableView._innerHeight then
			self.img_arrow:setVisible(false)
		else
			self.img_arrow:setVisible(true)
		end
	end
	self.tableView:setEventCall(_tableViewEvent)

	for i,v in ipairs(equip_sort) do
		self.menu_index = self.menu_index + 1
		local lable = self.tablePanel:clone()
		lable:setVisible(true)
		lable:setTitleText(equip_sort[self.menu_index].name)
		lable:setTag ( self.menu_index)
		lable:setPosition(cc.p( (self.menu_index - 1) * 127 , 5))
		self.btnList[i] = lable
		if self.btnList[self.openIndex] then
			self.btnList[self.openIndex]:setEnabled(false)
		end

		self.lableview:addChild(lable)

		lable:addClickEventListener(function ( ... )
			self.openIndex = lable:getTag()
			for i,v in ipairs(self.btnList) do
				if v:getTag() == self.openIndex then
					v:setEnabled(false)
				else
					v:setEnabled(true)
				end
			end
			
			self:_initViewData()
			self:SendMsg()
		end)
	end
	
end

function ZBRecycleForever:_initViewData()
	local zbItem_info={}
	self.ZBItem_Info={}
	for k,v in pairs(config_recycle_items) do
		if v.optype == 4 and v.equip_sort == self.openIndex then 
			table.insert(zbItem_info,v)
		end
	end

	table.sort(zbItem_info, function(a, b)
		local a_num = GGetItemNumById(a.item_id)
		local b_num = GGetItemNumById(b.item_id)

		if a_num == b_num then
			return a.entry < b.entry
		else
			return a_num > b_num
		end
	end)

	local tableList={}                     ------对数据进行合并，每两行数据合并成一行
	for k,v in pairs(zbItem_info) do
		if k%2 == 1 then
			for i,j in pairs(v) do
				tableList[i.."1"]=j
			end
		else
			for i,j in pairs(v) do
				local k_num = tonumber(k)/2
				tableList[i.."2"]=j
			end
		end

		if k%2==0 then                           
			table.insert(self.ZBItem_Info,tableList)
			local num = {}
			tableList=num
		end
	end
	if #zbItem_info % 2 == 1 then           ------当数据长度为单数时，最后一个不合并直接进表
		table.insert(self.ZBItem_Info,tableList)
	end
end

function ZBRecycleForever:updateCell(cell, data)
	local itemNode = cell
	local nodeLayer1=itemNode:getChildByName("nodeLayer1")
	local nodeLayer2=itemNode:getChildByName("nodeLayer2")

	local btn_huishou1 = UIBuilder.createByWidget(nodeLayer1:getChildByName("btn_huishou1"))
	local txt_num1 = UIBuilder.createByWidget(nodeLayer1:getChildByName("txt_num1"))
	local txt_name1 = UIBuilder.createByWidget(nodeLayer1:getChildByName("txt_name1"))
	local img_buy1 = UIBuilder.createByWidget(nodeLayer1:getChildByName("img_buy1"))
	local img_buy2 = UIBuilder.createByWidget(nodeLayer2:getChildByName("img_buy2"))
	local txt_shengyu1 = UIBuilder.createByWidget(nodeLayer1:getChildByName("txt_shengyu1"))
	local entry_id1 = 0
	local itemID = 0
	local itemdata1 = GGetItemDataById(data.item_id1)

	btn_huishou1:setTitleText("回收")
	btn_huishou1:setGrey(true)
	btn_huishou1:setEnabled(false)
	txt_name1:setString(itemdata1.name1)
	txt_name1:setColor(GItemColorByQuality(itemdata1.quality))  
	txt_num1:setString(data.recyle_gold1.."钻石")
	txt_shengyu1:setColor(cc.c3b(0,255,0))
	nodeLayer2:setVisible(true)

	for k,v in pairs(self.recycle_info) do
		if data.entry1 == v.record_entry_id or data.entry2 == v.record_entry_id then
			entry_id1 = k
			if data.item_num1 == 0 then
				txt_shengyu1:setString("无限制")
			else
				--txt_shengyu1:setString("剩余"..v.zb_residue_number.."件")
			end
		end
	end

	img_buy1:removeAllChildren()
	img_buy2:removeAllChildren()
	local list={}
	list[1]={itemid=data.item_id1,count=1,bind=1}
	local itempages = ItemsPage:create(list, 41,41,1,#list,nil,nil,nil,true,nil,nil,nil,false,true,true)
	img_buy1:addChild(itempages)

	local function onClickFunc1()
		if config_recycle_items[data.entry1] then
			local itemData = GGetItemDataById(config_recycle_items[data.entry1].item_id)
			if itemData.itemlevel >= 48 then
				local function cancelButtonCallBack()
		            ----
		        end
		        local  function okButtonCallback()
		           	self.huishou_data.shengyu = txt_shengyu1
					self.huishou_data.entry_id=entry_id1
					self.huishou_data.btn=btn_huishou1
					local protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_RECYCLE_ZB_FOREVER)
				    protocal.entry_id = data.entry1
					ProtocalPool.SendCMD(NET_ID, protocal)
		        end

		        local data1 = {
		            tips = "提   示",
		            tipsColor = cc.c3b(217, 214, 118),
		            content = "<COLOR VALUE=FFaea66f>   此装备阶级较高是否确认回收？</COLOR>",
		            isRich = true,
		            leftBtnText = "取消",
		            leftBtnCallBack = cancelButtonCallBack,
		            rightBtnText = "确定",
		            rightBtnCallBack = okButtonCallback,
		        }
		        local tips = BaseTipsDialog.new(data1)
		        self.parent:addChild(tips)

			else
				self.huishou_data.shengyu = txt_shengyu1
				self.huishou_data.entry_id=entry_id1
				self.huishou_data.btn=btn_huishou1
				local protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_RECYCLE_ZB_FOREVER)
			    protocal.entry_id = data.entry1
				ProtocalPool.SendCMD(NET_ID, protocal)
			end
		end
	end

	btn_huishou1:addClickEventListener(onClickFunc1)

	local flag = true
	if self.recycle_info[entry_id1] and self.recycle_info[entry_id1].zb_residue_number==0 and data.item_num1 ~= 0 then
		txt_shengyu1:setColor(cc.c3b(255,0,0))
		flag = false
	end
	if self.recycle_info[entry_id1] and self.recycle_info[entry_id1].is_recycle==0 then 
		btn_huishou1:setTitleText("已兑换")
	else
		local info=game_app.itemManager.bagList or {}
		for k,v in pairs(info) do
    	    if v.entry_id == data.item_id1 and flag and (v.ky_id and v.ky_id <= 0) then
    	    	btn_huishou1:setGrey(false)
				btn_huishou1:setEnabled(true)
   			end
		end
	end
	
	if data.entry2 then    --最后一个数据不存在，右边框则不显示
		local btn_huishou2 = UIBuilder.createByWidget(nodeLayer2:getChildByName("btn_huishou2"))
		local txt_num2 = UIBuilder.createByWidget(nodeLayer2:getChildByName("txt_num2"))
		local txt_name2 = UIBuilder.createByWidget(nodeLayer2:getChildByName("txt_name2"))
		local txt_shengyu2 = UIBuilder.createByWidget(nodeLayer2:getChildByName("txt_shengyu2"))
		local entry_id2 = 0
		local itemdata2 = GGetItemDataById(data.item_id2)
	
		btn_huishou2:setTitleText("回收")
		btn_huishou2:setGrey(true)
		btn_huishou2:setEnabled(false)
		txt_name2:setString(itemdata2.name1)
		txt_name2:setColor(GItemColorByQuality(itemdata2.quality)) 
		txt_num2:setString(data.recyle_gold2.."钻石")
		txt_shengyu2:setColor(cc.c3b(0,255,0))
	
		for k,v in pairs(self.recycle_info) do
			if data.entry2 == v.record_entry_id or data.entry2 == v.record_entry_id then
				entry_id2 = k
				if data.item_num2 == 0 then
					txt_shengyu2:setString("无限制")
				else
					--txt_shengyu2:setString("剩余"..v.zb_residue_number.."件")
				end
			end
		end

		list={}
		list[1]={itemid=data.item_id2,count=1,bind=1}
		itempages = ItemsPage:create(list, 41,41,1,#list,nil,nil,nil,true,nil,nil,nil,false,true,true)
		img_buy2:addChild(itempages)
	
		local function onClickFunc2()

			if config_recycle_items[data.entry2] then
				local itemData = GGetItemDataById(config_recycle_items[data.entry2].item_id)
				if itemData.itemlevel >= 48 then
					local function cancelButtonCallBack()
			            ----
			        end
			        local  function okButtonCallback()
			           	self.huishou_data.shengyu = txt_shengyu2
						self.huishou_data.entry_id=entry_id2
						self.huishou_data.btn=btn_huishou2
						local protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_RECYCLE_ZB_FOREVER)
					    protocal.entry_id = data.entry2
						ProtocalPool.SendCMD(NET_ID, protocal)
			        end

			        local data2 = {
			            tips = "提   示",
			            tipsColor = cc.c3b(217, 214, 118),
			            content = "<COLOR VALUE=FFaea66f>   此装备阶级较高是否确认回收？</COLOR>",
			            isRich = true,
			            leftBtnText = "取消",
			            leftBtnCallBack = cancelButtonCallBack,
			            rightBtnText = "确定",
			            rightBtnCallBack = okButtonCallback,
			        }
			        local tips = BaseTipsDialog.new(data2)
			        self.parent:addChild(tips)

				else
					self.huishou_data.shengyu = txt_shengyu2
					self.huishou_data.entry_id=entry_id2
					self.huishou_data.btn=btn_huishou2
					local protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_RECYCLE_ZB_FOREVER)
				    protocal.entry_id = data.entry2
					ProtocalPool.SendCMD(NET_ID, protocal)
				end
			end
		end
	
		btn_huishou2:addClickEventListener(onClickFunc2)

		local flag = true
		if self.recycle_info[entry_id2] and self.recycle_info[entry_id2].zb_residue_number==0 and data.item_num2 ~= 0 then
			txt_shengyu2:setColor(cc.c3b(255,0,0))
			flag =false
		end
		if self.recycle_info[entry_id2] and self.recycle_info[entry_id2].is_recycle==0 then 
			btn_huishou2:setTitleText("已兑换")
		else
			local info=game_app.itemManager.bagList or {}
			for k,v in pairs(info) do
    		    if v.entry_id == data.item_id2 and flag and (v.ky_id and v.ky_id <= 0) then
    		    	btn_huishou2:setGrey(false)
					btn_huishou2:setEnabled(true)
   				end
			end
		end
	else
		nodeLayer2:setVisible(false)
	end

	self:checkZBForeverRedState()
end

function ZBRecycleForever:SuccessGetMsgs()
	self:SendCMD(ProtocalCode.PT_RECYCLE_ZB_INFO,{recycle_type = 4})
	self:SendCMD(ProtocalCode.PT_RECYCLE_ALL_INFO)
	local num = tonumber(self.recycle_info[self.huishou_data.entry_id].zb_residue_number)-1
	--self.huishou_data.shengyu:setString("剩余"..num.."件")
end

function ZBRecycleForever:SendMsg()
	self:SendCMD(ProtocalCode.PT_RECYCLE_ZB_INFO,{recycle_type = 4})
end

function ZBRecycleForever:ListenNetWorkMsg(msg_type, msg_data)
	if ProtocalCode.PT_RECYCLE_ZB_INFO == msg_type then
		self.recycle_info = msg_data.recycle_info
		self:_initViewData()
		self:_initView()
		self.tableView:setListData(self.ZBItem_Info)
	elseif ProtocalCode.PT_RECYCLE_ZB_FOREVER  == msg_type then
		self:checkZBForeverRedState()
		if msg_data.is_success == 0 then
			self:SuccessGetMsgs()
			GShowTipsMsg("回收成功")
		elseif msg_data.is_success == 1 then
			GShowTipsMsg("回收失败,未拥有该道具")
		elseif msg_data.is_success == 2 then
			GShowTipsMsg("回收失败,该商品已兑换完")
		elseif msg_data.is_success == 3 then
			GShowTipsMsg("回收失败,已兑换过该道具")
		else
			GShowTipsMsg("回收失败")
		end

		--请求最新数据
		local protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_RECYCLE_ALL_INFO)
		ProtocalPool.SendCMD(NET_ID,protocal)
	end
end

--装备永久回收红点检测
function ZBRecycleForever:checkZBForeverRedState()
	local info=game_app.itemManager.bagList or {}
	local redList = {}
    for k1,v1 in pairs(config_recycle_items) do
		for k,v in pairs(info) do
			if v.entry_id == v1.item_id and v1.optype == 4 and (v.ky_id and v.ky_id <= 0) then 
				table.insert( redList, v1.equip_sort )
			end
		end
	end

	for i=1,#self.btnList do
		UIBuilder.onAddRedDot(self.btnList[i], false, 105, 40)	
	end
	if redList then
		for i=1,#redList do
			UIBuilder.onAddRedDot(self.btnList[redList[i]], true, 105, 40)
		end
	end
end


function ZBRecycleForever:destroy()
	self.super.destroy(self)
end

return ZBRecycleForever