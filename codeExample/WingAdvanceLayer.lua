--
--	Author: yhw	
--	Date: 2020-09-06
--	神翼-升阶
local UILayerbase = import("...base/UILayerbase")
local WingAdvanceLayer = class("WingAdvanceLayer",UILayerbase)

local WingGiftLayer = import(".WingGiftLayer")

require "scripts/cnf/wings"
require "scripts/cnf/wingsequip"
local WingConfig = GameConfig.wings
local WingsEquipConfig = GameConfig.wingsequip

--升阶消耗物品Id
local NeedItemId = 10201

local wing_LevelInfo={"一\n阶","二\n阶","三\n阶","四\n阶","五\n阶","六\n阶","七\n阶","八\n阶","九\n阶","十\n阶","十\n一\n阶","十\n二\n阶","十\n三\n阶","十\n四\n阶","十\n五\n阶","十\n六\n阶", "十\n七\n阶", "十\n八\n阶", "十\n九\n阶", "二\n十\n阶", [0]="零\n阶"}

function WingAdvanceLayer:ctor()
	self.super.ctor(self)
	self.LAYER_ID = 1
	self.csbfile = "wing/WingAdvanceLayer.csb"
	self.res_list = {

	}

	self.wing_equip_power = 0
	--是否自动升阶
	self.isGoingFlag = false
end

function WingAdvanceLayer:create()
	self.super.create(self)

	self.powerTxt = self:seekNode("power_txt")
	self.titleLab1 = self:seekNode("wing_title_lab1")

	--满级后隐藏的层
	self.hideLayer = self:seekNode("hide_layer")
	self.fullBtn = UIBuilder.createByWidget(self:seekNode("full_btn"))

	self.atkTxt = self:seekNode("atk_txt")
	self.hpTxt = self:seekNode("hp_txt")
	self.defTxt = self:seekNode("def_txt")
	self.reduceTxt = self:seekNode("reduce_txt")

	self.atkNextTxt = self:seekNode("atk_next_txt")
	self.hpNextTxt = self:seekNode("hp_next_txt")
	self.defNextTxt = self:seekNode("def_next_txt")
	self.reduceNextTxt = self:seekNode("reduce_next_txt")

	self.wingBar = self:seekNode("wing_bar")
	self.wingBarTxt = self:seekNode("wing_exp_lab")

	self.wingNumTxt = self:seekNode("wing_num_lab")
	self.autoBuyBtn = UIBuilder.createByWidget(self:seekNode("auto_buy_btn"))

	self.goBtn = UIBuilder.createByWidget(self:seekNode("go_btn"))
	self.goingBtn = UIBuilder.createByWidget(self:seekNode("going_btn"))

	self.wingJhLayer = self:seekNode("wing_jh_layer")
	self.wingjhBtn = UIBuilder.createByWidget(self:seekNode("wing_jh_btn"))

	self.showBtn = UIBuilder.createByWidget(self:seekNode("show_btn"))
	self.nameImg = self:seekNode("wing_name_img")
	self.stageTxt = self:seekNode("wing_jie_lab")

	self.equipNameBg = self:seekNode("equip_name_bg")
	self.equipNameTxt = self:seekNode("equip_name_txt")
	--幻羽显示提示(暂时没判断)
	self.fasionShowTxt = self:seekNode("fasion_show_txt")

	self.leftBtn = UIBuilder.createByWidget(self:seekNode("wing_left_btn"))
	self.rightBtn = UIBuilder.createByWidget(self:seekNode("wing_right_btn"))

	self.equipItemLayer = self:seekNode("equip_item_layer")

	self.wingModelLayer = self:seekNode("wing_model_layer")

	self:_initView()
	self:_initEvent()

	WingManager:getInstance():req_wing_info()

	return self
end

function WingAdvanceLayer:_initView()
	local openday =PrivateStateManager:getInstance():GetRDays()--开服天数
	if openday > 12 then
		self.itemsPage = ItemsPage:create(nil, 42, 42, 1, 6, 2)
		self.equipItemLayer:addChild(self.itemsPage)
		local equip_Img={[1]="nimg_cbdj_1.png",[2]="nimg_cbdj_2.png",[3]="nimg_cbdj_3.png",[4]="nimg_cbdj_4.png",[5]="nimg_cbdj_5.png",[6]="nimg_cbdj_6.png"}
		for i,v in ipairs(equip_Img) do
			local item = self.itemsPage:getItemCellByIndex(i)
			item:setItemBackGround(v)
		end
	else
		self.equipNameBg:setVisible(false)
		self.equipNameTxt:setVisible(false)
	end

	local data = WingManager:getInstance().data_info
	self:_setData(data)
end

function WingAdvanceLayer:_initEvent()
	self.wingjhBtn:addClickEventListener(function()
		--激活
		WingManager:getInstance():req_wing_upgrade(0)
	end)

	local isAutoBuy = WingManager:getInstance().isAutoBuy
	self.autoBuyBtn:setBright(not isAutoBuy)
	self.autoBuyBtn:addClickEventListener(function()
		WingManager:getInstance().isAutoBuy = not WingManager:getInstance().isAutoBuy
		local isAutoBuy = WingManager:getInstance().isAutoBuy
		self.autoBuyBtn:setBright(not isAutoBuy)
	end)

	self.goBtn:addClickEventListener(function()
		--升阶
		self.goingBtn:setTitleText("自动升阶")

		local isAutoBuy = WingManager:getInstance().isAutoBuy
		if isAutoBuy == true then
			WingManager:getInstance():req_wing_upgrade(1)
		elseif self.curNum < self.needNum then
			--弹窗购买
			self:handleItemBuy()
		else
			WingManager:getInstance():req_wing_upgrade(0)
		end
	end)

	self.goingBtn:addClickEventListener(function()
		--自动升阶(Updata里执行)
		if self.isGoingFlag == false then
			self.isGoingFlag = true
			self.goingBtn:setTitleText("停止升阶")
		else
			self.isGoingFlag = false
			self.goingBtn:setTitleText("自动升阶")
			return 
		end

		--先执行一次
		local isAutoBuy = WingManager:getInstance().isAutoBuy
		if isAutoBuy == true then
			WingManager:getInstance():req_wing_upgrade(1)
		elseif self.curNum < self.needNum then
			--弹窗购买
			self:handleItemBuy()
			self.isGoingFlag = false
			self.goingBtn:setTitleText("自动升阶")
		else
			WingManager:getInstance():req_wing_upgrade(0)
		end

	end)


	self.showBtn:addClickEventListener(function()
		if self.index > self.data.wing_level then
			--不能使用
		else
			local isBright = self.showBtn:isBright()
			if isBright then
				--显示模型
				WingManager:getInstance():req_wing_show(1, self.index)
			else
				--隐藏模型
				WingManager:getInstance():req_wing_show(0)
			end
		end
	end)

	self.leftBtn:addClickEventListener(function()
		local index = self.index
		index = index - 1
		if index <= 0 then
			index = 1
		end

		self:_updateModelView(index)
	end)

	self.rightBtn:addClickEventListener(function()
		local index = self.index
		index = index + 1 
		local maxIndex = math.min(self.data.wing_level+1, 20)
		if index > maxIndex then
			index = maxIndex
		end

		self:_updateModelView(index)
	end)

	self.itemChange = function ( ... )
		if self.needNum then
			self.curNum = GGetItemNumById(NeedItemId)
			self.wingNumTxt:setString(self.curNum .. "/" .. self.needNum)
			
			if self.curNum >= self.needNum then
				self.wingNumTxt:setTextColor(cc.c4b(0,255,0,255))
			else
				self.wingNumTxt:setTextColor(cc.c4b(255,0,0,255))
			end
		end
	end
	
	game_app:BindGameNotify(GameConfig.NOTIFY_ITEM_CHANGE, self.itemChange)
end

function WingAdvanceLayer:_setData(data)
	if data == nil then return end
	self.data = data

	self.titleLab1:setString("当前翅膀属性")
	local wing_level = self.data.wing_level or 0
	if wing_level <= 0 then
		--未激活
		self.wingJhLayer:setVisible(true)
		self.titleLab1:setString("激活翅膀属性")
	elseif wing_level >= 20 then
		--满级
		self.hideLayer:setVisible(false)
		self.fullBtn:setVisible(true)
	else
		self.wingJhLayer:setVisible(false)
		self.hideLayer:setVisible(true)
		self.fullBtn:setVisible(false)
	end

	local _config = WingConfig[wing_level]
	if _config == nil then
		_config = WingConfig[1]
		self.powerTxt:setString(0)
	else
		self.powerTxt:setString(_config.battle + self.wing_equip_power)
	end
	local _nextConfig = WingConfig[wing_level + 1]
	local job = GGetPlayerAttr("job")
	

	--当前阶段属性
	self.atkTxt:setString(_config.minAttack .. "-" .. _config.maxAttack)
	local hpStr = string.split(_config.HP, ",")
	self.hpTxt:setString(hpStr[job])
	self.defTxt:setString(_config.minAC .. "-" .. _config.maxAC)
	self.reduceTxt:setString((_config.ExemptDamage / 100) .. "%")

	--下一阶段属性
	if _nextConfig then
		self.atkNextTxt:setString(_nextConfig.minAttack .. "-" .. _nextConfig.maxAttack)
		local hpStr = string.split(_nextConfig.HP, ",")
		self.hpNextTxt:setString(hpStr[job])
		self.defNextTxt:setString(_nextConfig.minAC .. "-" .. _nextConfig.maxAC)
		self.reduceNextTxt:setString((_nextConfig.ExemptDamage / 100) .. "%")

		self.wingBarTxt:setString(self.data.wing_exp .. "/" .. _nextConfig.maxExp)
		if wing_level <= 0 then
			self.wingBar:setPercent(0)
		else
			self.wingBar:setPercent(self.data.wing_exp / _nextConfig.maxExp * 100)
		end

		self.curNum = GGetItemNumById(NeedItemId)
		self.needNum = _nextConfig.count
		self.wingNumTxt:setString(self.curNum .. "/" .. self.needNum)
		if self.curNum >= self.needNum then
			self.wingNumTxt:setTextColor(cc.c4b(0,255,0,255))
		else
			self.wingNumTxt:setTextColor(cc.c4b(255,0,0,255))
		end
	end

	
end

function WingAdvanceLayer:_updateModelView(index)
	local show_modeone = game_app:role_data().show_modeone or 1000
	local isShow = Utils:get_bit_by_position(show_modeone, 5)

	if index == 0 then
		index = 1
	end

	local _config = WingConfig[index]

	if _config then
		if isShow == 1 and self.data.wing_mode == _config.displayId then
			--显示外观
			self.showBtn:setBright(false)
		else
			--不显示外观
			self.showBtn:setBright(true)
		end
	end

	local nameImgStr = "nimg_shenyimc_" .. index .. ".png"
	
	self.nameImg:loadTexture(nameImgStr, 1)

	self.stageTxt:setString(wing_LevelInfo[index])

	--箭头更新
	self.leftBtn:setVisible(index > 1)
	local maxIndex = math.min(self.data.wing_level+1, 20)
	self.rightBtn:setVisible(index < maxIndex)

	--创建翅膀
	if self.index ~= index then
		if self.wingModel then
			self.wingModel:destroy()
			self.wingModel = nil
		end
		self.wingModel = UIBuilder.createWingEffect(_config.displayId, 0, 0, self.wingModelLayer, 0.18 , true, false)
		if self.wingModel_1 then
			self.wingModel_1:destroy()
			self.wingModel_1 = nil
		end
		self.wingModel_1 = UIBuilder.createWingEffect(_config.displayId, 25, 0, self.wingModelLayer, 0.18 , true, false)
		self.wingModel_1:get_real_sprite():setFlippedX( true )
	end

	self.index = index
end

--道具不足处理
function WingAdvanceLayer:handleItemBuy()
	local openday =PrivateStateManager:getInstance():GetRDays()--开服天数
	if openday <= 7 and KFHDManager:getInstance():check_enter_change2() then
		--弹窗购买礼包
		local layer = WingGiftLayer:create()
		GameWorld.Layer:get_layer_info():addChild(layer)
		layer:setPosition(cc.p(SCREEN_SIZE.width*0.5,SCREEN_SIZE.height*0.5))
		return 
	end

	--购买道具
	UIBuilder.createQuickBuy(13)
end

--翅膀装备处理
function WingAdvanceLayer:_setWingEquip(data)
	--装备增加的战力
	self.wing_equip_power = 0

	local wing_equip_list = {data.wing_equip1,data.wing_equip2,data.wing_equip3,data.wing_equip4,data.wing_equip5,data.wing_equip6}
	local openday = PrivateStateManager:getInstance():GetRDays()--开服天数
	if openday >= 15 then
		for i,v in ipairs(wing_equip_list) do
			if v > 0 then
				local item = self.itemsPage:getItemCellByIndex(i)
				item:updateByItem({entry_id = WingsEquipConfig[v].equipId, bind = 1, pack_id=0})

				self.wing_equip_power = self.wing_equip_power + WingsEquipConfig[v].battle
			end
		end
	end
end

---监听网络消息
function WingAdvanceLayer:ListenNetWorkMsg(msg_type, msg_data)
	if msg_type == ProtocalCode.PT_WingInfo then
		--初始化
		self:_setWingEquip(msg_data)
		self:_setData(msg_data)
		local index = 1
		if self.data.wing_level > 0 then
			for _,v in ipairs(WingConfig) do
				if v.displayId == self.data.wing_mode then
					index = v.entry
					break
				end
			end
		end
		self:_updateModelView(self.data.wing_level)
     elseif msg_type == ProtocalCode.PT_SetWingUp then
     	--激活升级
     	if self.data.wing_level < msg_data.level then
     		--升阶停止自动升阶
     		self.isGoingFlag = false
			self.goingBtn:setTitleText("自动升阶")
     	end
     	self.data.wing_level = msg_data.level
     	self.data.wing_exp = msg_data.exp

     	self:_setData(self.data)

     	self:_updateModelView(self.data.wing_level)
    --elseif msg_type == ProtocalCode.PT_Wingdata then
    	--暂时不知道这协议干嘛的
    elseif msg_type == ProtocalCode.PT_Player_Info_Update then
    	if GGetPlayerAttr("user_id") == msg_data.id then
    		if msg_data.info and msg_data.info.wing_level then
		    	self.data.wing_mode = msg_data.info.mode
		        self.data.wing_level = msg_data.info.wing_level

		     	self:_updateModelView(self.index)
		    end
	    end
	end
end

--界面刷新
local _timeIndex = 0
function WingAdvanceLayer:Updata(dt)
	if self.isGoingFlag then
		_timeIndex = _timeIndex + 1
		if _timeIndex >= 20 then
			if WingManager:getInstance().isAutoBuy == true then
				WingManager:getInstance():req_wing_upgrade(1)
			elseif self.curNum < self.needNum then
				--弹窗购买
				self:handleItemBuy()
				self.isGoingFlag = false
				self.goingBtn:setTitleText("自动升阶")
			else
				WingManager:getInstance():req_wing_upgrade(0)
			end
			_timeIndex = 0
		end
	end
end

function WingAdvanceLayer:destroy()
	game_app:CancelGameNotify(GameConfig.NOTIFY_ITEM_CHANGE, self.itemChange)
	self.super.destroy(self)

	if self.wingModel then
		self.wingModel:destroy()
		self.wingModel = nil
	end
	if self.wingModel_1 then
		self.wingModel_1:destroy()
		self.wingModel_1 = nil
	end
end

return WingAdvanceLayer