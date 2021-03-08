--
--	Author: yhw
--	Date: 2020-08-24
--	灵谱-灵谱
local UILayerbase = import("...base/UILayerbase")
local TupuLayer = class("TupuLayer",UILayerbase)

local qualityColor = GQualityColorByChat

require "scripts/cnf/cnfmappropertiesname"
require "scripts/cnf/cnfmapproperties"
local CnfMappropertiesname = GameConfig.CnfMappropertiesname
local CnfMapproperties = GameConfig.CnfMapproperties

local TupuMenuCell = import(".TupuMenuCell")
local TupuCell = import(".TupuCell")

function TupuLayer:ctor()
	self.super.ctor(self)
	self.LAYER_ID = 1
	self.csbfile = "tupu/TupuLayer.csb"
	self.res_list = {

	}
end

function TupuLayer:create()
	self.super.create(self)
	self.btnList = {}
	self.redList = {}

	self.menuLayer = self:seekNode("menu_layer")
	for i=1,5 do
		self["topSelectBtn_"..i] = self:seekNode("select_btn_"..i)
		self["topRed_"..i] = self:seekNode("red_"..i)
		
		self["topSelectBtn_"..i]:setVisible(false)
		table.insert(self.btnList, self["topSelectBtn_"..i])
		table.insert(self.redList, self["topRed_"..i])
	end

	self.listView = self:seekNode("listview")
	self.listView:setScrollBarEnabled(false)
	self.listView:setItemsMargin(7)
	self.listViewArrow = self:seekNode("listview_arrow")
	self.listViewArrow:setVisible(false)
	self.infoLayer = self:seekNode("info_layer")
	self.powerTxt = self:seekNode("power_txt")
	self.tupuIcon = self:seekNode("tupu_icon")

	for i=1,5 do
		self["starBg_"..i] = self:seekNode("star_bg_"..i)
		self["star_"..i] = self:seekNode("star_"..i)
	end

	for i=1,4 do
		self["propertyTxt_"..i] = self:seekNode("property_txt_"..i)
	end

	self.needTxt = self:seekNode("need_txt")
	self.richtextLayer = self:seekNode("richtext_layer")
	self.upgradeBtn = self:seekNode("upgrade_btn")
	self.fullTxt = self:seekNode("full_txt")

	self.richText = ccui.RichText:create()
	self.richText:setContentSize(cc.size(250,20))
	self.richText:ignoreContentAdaptWithSize(false)
	self.richText:setAnchorPoint(cc.p(0,0))
	self.richText:setPosition(cc.p(0,0))
	self.richtextLayer:addChild(self.richText)

	self:_initEvent()
	self:_initMenu()
	return self
end

function TupuLayer:_initEvent()
	for i=1,3 do
		self["topSelectBtn_"..i]:addClickEventListener(function()
			self:setSelectTopBtn(i)
		end)
	end
	local function _scrollViewEvent(sender, eventType)
		if eventType ~= 9 then
			if self.listView:getContentSize().height >= self.listView:getInnerContainerSize().height then
				self.listViewArrow:setVisible(false)
				return 
			end
			if self.listView:getInnerContainerPosition().y >= 0 then
				self.listViewArrow:setVisible(false)
			else
				self.listViewArrow:setVisible(true)
			end
		end
	end
	self.listView:addScrollViewEventListener(_scrollViewEvent)

	local function _upgradeCallback()
		--暂时没判断道具不足弹出道具获取途径
		TupuManager:getInstance():req_upgrade(self.selMenuIndex, self.selTopIndex, self.selInfoIndex)
	end
	self.upgradeBtn:addClickEventListener(_upgradeCallback)
end

function TupuLayer:_initMenu()
	local layer = ccui.Layout:create()
	layer:setContentSize(cc.size(251, 66))
	self:addChild(layer)
	local _tableSize = self.menuLayer:getContentSize()
	self.menuTableView = UIBuilder.CreateUITableView(0,0,_tableSize.width,_tableSize.height,layer,handler(self,self["updateMenuCell"]),self.menuLayer)
	self.menuTableView:setItemsMargin(5)
	self.menuTableView:setListData(CnfMappropertiesname)
	self:setSelectMenu(1)
end


function TupuLayer:updateMenuCell(cell, data, idx)
	cell:removeAllChildren()
	local node = TupuMenuCell.new(self)
	node:setData(data)
	cell:addChild(node)

	if self.selMenuIndex == idx then
		node:setIsSelected(true)
	else
		node:setIsSelected(false)
	end
end

function TupuLayer:setSelectMenu(index)
	if self.selMenuIndex == index then return end

	self.selMenuIndex = index
	self.menuTableView:refreshView()
	--update
	self:_updateTopBtn()
	self:initListView()
end

function TupuLayer:_updateTopBtn(index)
	if index == nil then
		self.firstId = nil
		for _,v in ipairs(self.btnList) do
			v:setVisible(false)
		end
    
		for i,v in ipairs(CnfMappropertiesname[self.selMenuIndex].havetype) do
			if self.btnList[v] then
				self.btnList[v]:setVisible(true)
			end
			if self.firstId == nil then
				self.firstId = i
			end
		end
	end
		--这里处理顶部按钮和红点位置
		local tmpIndex = 1
		for i,v in ipairs(self.btnList) do
			if v and v:isVisible() then
				local pos_x = 323+(tmpIndex-1)*132
				local pos_y = 571
				v:setPosition(cc.p(pos_x, pos_y))
				tmpIndex = tmpIndex + 1
			end
		end

	self.selTopIndex = index or self.firstId

	for i,v in ipairs(self.btnList) do
		if i == self.selTopIndex then
			v:loadTextures("mbxan_1.png", nil, nil, 1)
		else
			v:loadTextures("mbxan_2.png", nil, nil, 1)
		end
	end
 
end

function TupuLayer:setSelectTopBtn(index)
	if self.selTopIndex == index then return end

	self:_updateTopBtn(index)

	self:initListView()
end

function TupuLayer:initListView()
	self.boss_info={}
	local datalist = TupuManager:getInstance().datalist
    for i,v in ipairs(datalist) do
        if v.type==self.selMenuIndex and v.pos==self.selTopIndex then
            table.insert(self.boss_info,v)
        end
    end
    for i=1,5 do
    	if TupuManager.getInstance().typeList[self.selMenuIndex] then
    		if TupuManager.getInstance().typeList[self.selMenuIndex][i] then
    			self["topRed_"..i]:setVisible(true)
    		else
    			self["topRed_"..i]:setVisible(false)
    	    end
    	else 
   	         self["topRed_"..i]:setVisible(false)
    	end
    end
    table.sort(self.boss_info, function(a, b)   return a.pos1 < b.pos1  end )
    self.listView:removeAllChildren()
    self.cellList = {}
    self.infoLayer:setVisible(false)
    self.selInfoIndex = nil

    --计算行数
	local rows = math.floor(#self.boss_info / 2)
	if #self.boss_info % 2 > 0 then
		rows = rows + 1
	end
	for i=1,rows do
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(465,254))
		for j=1,2 do
			local index = (i-1)*2 + j
			if self.boss_info[index] == nil then
				break
			end
			local cell = TupuCell.new(self)
			cell:setData(self.boss_info[index])
			layout:addChild(cell)
			local pos_x = (229 + 7) * (j - 1)
			cell:setPosition(cc.p(pos_x,0))
			table.insert(self.cellList, cell)
		end
		self.listView:pushBackCustomItem(layout)
	end

	if (rows*229) + (rows-1)*7 > self.listView:getContentSize().height then
		self.listViewArrow:setVisible(true)
	else
		self.listViewArrow:setVisible(false)
	end
  
end

function TupuLayer:updateListView()
	for i,v in ipairs(self.cellList) do
		if self.boss_info[i] and v then
			v:setData(self.boss_info[i])
		end
	end
end

--选择卡片(index ----> pos1)
function TupuLayer:setSelectBossInfo(index)
	for i,v in ipairs(self.cellList) do
		v:setSelected(i == index)
	end

	self:updateInfoView(index)
end

function TupuLayer:updateInfoView(index)
	self.infoLayer:setVisible(true)
	self.selInfoIndex = index

	local info = self.boss_info[index]
	local datalevellist = TupuManager:getInstance().datalevellist
	local level = datalevellist[info.id]

	self:_setStar(level, info.upnum)

	local keyid = nil
	if level > 0 then
		keyid = info.type*1000000+info.pos*100000+info.valuetype*100+level
		self.upgradeBtn:setTitleText("升 级")
	else
		keyid = info.type*1000000+info.pos*100000+info.valuetype*100+1
		self.upgradeBtn:setTitleText("激 活")
	end
	local entry = CnfMapproperties[keyid]
	if entry then
		local strlist = self:getstrlist(entry)
		for i=1,4 do
			self["propertyTxt_"..i]:setString(strlist[i] or " ")
		end
		self.powerTxt:setString(entry.zhanli)
	else
		for i=1,4 do
			self["propertyTxt_"..i]:setString(" ")
		end
		self.powerTxt:setString("")
	end

	self.tupuIcon:loadTexture(info.iconID .. ".png", 1)

	local need_item_id=info.need_item_id[level+1]
	if not need_item_id then
		need_item_id=info.need_item_id[1]
	end
	local item_num=info.item_num[level+1]
	if not item_num then
		item_num=info.item_num[1]
	end
	local shopid=info.shopid[level+1]
	if not shopid then
		shopid=info.shopid[1]
	end

	local itemData = GGetItemDataById(need_item_id)
	local goodsQuality=itemData.quality
	local strNum=""
	if GGetBagItemNumAndList(need_item_id)>=item_num then
		strNum="<COLOR VALUE=FF00FF00>×"..item_num .."</COLOR>"
	else
		strNum="<COLOR VALUE=FFFF0000>×"..item_num .."</COLOR>"
	end
	self.richText:setText(qualityColor[goodsQuality] ..itemData.name1 .."</COLOR>"..strNum, nil, 19)
	--满级判断
	if level >= info.upnum then
		self.needTxt:setVisible(false)
		self.richtextLayer:setVisible(false)
		self.upgradeBtn:setVisible(false)
		self.fullTxt:setVisible(true)
	else
		self.needTxt:setVisible(true)
		self.richtextLayer:setVisible(true)
		self.upgradeBtn:setVisible(true)
		self.fullTxt:setVisible(false)
	end

	for i,v in ipairs(GameConfig.CnfMappropertiesname[self.selMenuIndex].havetype) do
		   if TupuManager.getInstance().typeList[self.selMenuIndex] then
		        if TupuManager.getInstance().typeList[self.selMenuIndex][v] then
				     self["topRed_"..v]:setVisible(true)
		        else 		 
		   	         self["topRed_"..v]:setVisible(false)
	            end
	       else 
	    	         self["topRed_"..v]:setVisible(false)
	       end
	   end

end

function TupuLayer:_setStar(level, max)
	local starType = math.floor(level / 5)
	if level == 0 or level%5 > 0 then
		starType = starType + 1
	end
	for i=1,5 do
		self["starBg_"..i]:setVisible(false)
		self["star_"..i]:setVisible(false)

		self["starBg_"..i]:loadTexture("bnim_xingxing_"..starType..".png", 1)
		self["star_"..i]:loadTexture("nim_xingxing_"..starType..".png", 1)
	end

	--星星背景数量
	local starBgCount = max >= 5 and 5 or max
	for i=1,starBgCount do
		self["starBg_"..i]:setVisible(true)
	end

	local starCount = level % starBgCount
	if level > 0 and starCount == 0 then
		starCount = starBgCount
	end

	for i=1,starCount do
		self["star_"..i]:setVisible(true)
	end
end

function TupuLayer:getstrlist(entry)
	local strlist = {}
	if entry.minphysicsattack>0 or entry.maxphysicsattack>0 then
		local str = "攻击:"..entry.minphysicsattack.."-"..entry.maxphysicsattack
		table.insert(strlist,str)
	end
	if entry.minphysicsguard>0 or entry.maxphysicsguard>0 then
		local str = "防御:"..entry.minphysicsguard.."-"..entry.maxphysicsguard
		table.insert(strlist,str)
	end
	if entry.life1>0 then
		local str = "生命:"..entry.life1
		table.insert(strlist,str)
	end
	if entry.attackPer>0 then
		local str = "人物攻击加成:"..(entry.attackPer/100).."%"
		table.insert(strlist,str)
	end
	if entry.goldrecovery>0 then
		local str = "回收元宝:"..(entry.goldrecovery/100).."%"
		table.insert(strlist,str)
	end
	if entry.poisonhurt>0 then
		local str = "中毒威力:"..entry.poisonhurt.."%"
		table.insert(strlist,str)
	end
	if entry.pethurt>0 then
		local str = "神将伤害:"..(entry.pethurt/100).."%"
		table.insert(strlist,str)
	end
	if entry.bosshurt>0 then
		local str = "BOSS伤害加成:"..(entry.bosshurt/100).."%"
		table.insert(strlist,str)
	end
	if entry.defense>0 then
		local str = "防御加成:"..(entry.defense/100).."%"
		table.insert(strlist,str)
	end
	if entry.hut>0 then
		local str = "攻击加成:"..(entry.hut/100).."%"
		table.insert(strlist,str)
	end
	if entry.ignore_defense>0 then
		local str = "忽视防御:"..(entry.ignore_defense/100).."%"
		table.insert(strlist,str)
	end
	if entry.speed>0 then
		local str = "攻击速度:"..(entry.speed/100).."%"
		table.insert(strlist,str)
	end
	return strlist
end

---监听网络消息
function TupuLayer:ListenNetWorkMsg(msg_type, msg_data)
	if msg_type == ProtocalCode.PT_HANDBOOK_GET_INFO then
		self:updateListView()
		if self.selInfoIndex then
			self:updateInfoView(self.selInfoIndex)
		end
		if self.menuTableView then
			self.menuTableView:setListData(CnfMappropertiesname)
		end
	end
end

return TupuLayer