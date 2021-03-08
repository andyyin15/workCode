--
--author yhw
--date 2020/12/24
--星耀节点
--
local UILayerbase = import("...base/UILayerbase")

require "scripts/cnf/Quest_titles_config"
require "scripts/cnf/Quest_achievement_config"

local XingyaoCell1 = import(".XingyaoCell1")
local XingyaoCell2 = import(".XingyaoCell2")

local XingyaoNode = class("XingyaoNode", UILayerbase)

function XingyaoNode:ctor()
	self.super.ctor(self)
    self.name = "XingyaoNode"
    self.csbfile = "xingyao/xingyaoNode.csb"
    self.callback = handler(self, self.onTouchCallBack)
end

function XingyaoNode:create(_parent)
	self.super.create(self)
	self.parent = _parent
	self.game_layer = ccui.Helper:seekWidgetByName(self._widget,"game_layer")

	self.item_node = self.game_layer:getChildByName("item_node")
	self.btn_get = self.game_layer:getChildByName("btn_get")

    self.load_bar = self.game_layer:getChildByName("load_bar")

    self.img_prefession = self.game_layer:getChildByName("img_prefession")

    self.num = self.game_layer:getChildByName("num")
	self.left_scrollview = self.game_layer:getChildByName("left_scrollview")
	self.left_scrollview:setScrollBarEnabled(false)

	self.right_scrollview = self.game_layer:getChildByName("right_scrollview")
	self.right_scrollview:setScrollBarEnabled(false)

	self.cur_select_index = 1
	self.menu_list = {}
	self.red_config = {0,0,0,0,0,0}

    self:createBtnEffect()
	self:initEvent()
	self:sortConfig()
	self:createScrollContent()
	self:updateRed()

	return self
end

function XingyaoNode:createBtnEffect()
    self.btnEffect = UIBuilder.CreateEffect(1150, self.btn_get:getContentSize().width/2 -2, self.btn_get:getContentSize().height /2 -2, self.btn_get, nil, true, false)
    self.btnEffect:setVisible(false)
end

function XingyaoNode:initEvent()
		
	self.privateUpdate = function()
		self:updateMenuContent()
		self:updateRed()
	end

	for key, value in pairs(PrivateStateManager:getInstance().private_state_array) do
		game_app:BindGameNotify(GameConfig.PRIVATE_STATE_UPDATE_ONE+key, self.privateUpdate)
	end
end

function XingyaoNode:sortConfig()
	self.is_lock = {}
    self.info_config = {}
    for i=1,6 do
        self.info_config[i] = {}
        for k,v in ipairs(Quest_titles_config) do
            if i == v.type then
                table.insert(self.info_config[i],v)
            end
        end
    end

    for i=1,6 do
        local get_num = 0
        for i,v in ipairs(self.info_config[i]) do
            local bit_param = PrivateStateManager:getInstance():GetStateValue(v.bitparam)
            if Utils:get_bit_by_position(bit_param, v.parambit)==1 then
                get_num = get_num + 1
            end
        end
        if get_num == 8 then
            local sum_param = PrivateStateManager:getInstance():GetStateValue(Quest_achievement_config[i].param)
            if Utils:get_bit_by_position(sum_param,Quest_achievement_config[i].parambit) == 0 then
                self.is_lock[i] = 0
            else
                self.is_lock[i] = 1  --已解锁
            end
        else
            self.is_lock[i] = 0
        end
    end

    for i=6, 1, -1 do
        if self.is_lock[i] == 1 then
            self.cur_select_index = i + 1
            if self.cur_select_index > 6 then
                self.cur_select_index = 6
            end
            break
        end
    end
end

function XingyaoNode:createScrollContent()
	local width = #Quest_achievement_config * 130 >= 945 and #Quest_achievement_config * 130 or 945
	self.left_scrollview:setInnerContainerSize(cc.size(width, 70))
    self.left_scrollview:setTouchEnabled(false)
	for i=1, #Quest_achievement_config do
		local node = XingyaoCell1.new(self)
		node:setPosition( cc.p((i-1)* 130, 10))
        node:setTag(i)
		node:freshContent(Quest_achievement_config[i])
		table.insert(self.menu_list, node)
		self.left_scrollview:addChild(node)
	end

    self:updateMenuContent()
end

function XingyaoNode:updateMenuContent()

    self.img_prefession:loadTexture(string.format("nbg_bannerzi_%d.png", math.ceil(self.cur_select_index / 2)), 1)

	local itemList = Quest_achievement_config[self.cur_select_index].reward_list
	if self.itemPage then
		self.itemPage:updateCellByList(itemList)
	else
		self.itemPage = ItemsPage:create(itemList, -86, 10, 1, 3, 5, 15, nil, false, nil, nil, nil, false, true, true)
		self.item_node:addChild(self.itemPage)
	end

    if self.itemPage then
        for i=1,#itemList do
            self.itemPage:getItemCellByIndex(i):showItemSname(true)
        end
    end

	 for i=1, #self.menu_list do
        if i == self.cur_select_index then
            self.menu_list[i]:setSelectImgState(true)
        else
            self.menu_list[i]:setSelectImgState(false)
        end
    end

    local get_reward = PrivateStateManager:getInstance():GetStateValue(1171)
    if Utils:get_bit_by_position(get_reward,self.cur_select_index)==1 then
        self.btn_get:setEnabled(false)
        self.btn_get:setBright(false)
        self.btn_get:setTitleText("已领取")
        self.btnEffect:setVisible(false)
    else
        local get_num = 0
        for i,v in ipairs(self.info_config[self.cur_select_index]) do
            local bit_param = PrivateStateManager:getInstance():GetStateValue(v.bitparam)
            if Utils:get_bit_by_position(bit_param,v.parambit)==1 then
                get_num = get_num + 1
            end
        end

        if get_num == 8 then
            self.btn_get:setEnabled(true)
            self.btn_get:setBright(true)
            self.btn_get:setTitleText("领取奖励")
            self.btnEffect:setVisible(true)
        else
            self.btn_get:setEnabled(false)
            self.btn_get:setBright(false)
            self.btn_get:setTitleText("领取奖励")
            self.btnEffect:setVisible(false)
        end       
    end

    local config = self.info_config[self.cur_select_index]

    table.sort(config, function(a, b)
        local a_condition = PrivateStateManager:getInstance():GetStateValue(a.param)
        local b_condition = PrivateStateManager:getInstance():GetStateValue(b.param)

        local a_isget = PrivateStateManager:getInstance():GetStateValue(a.bitparam)
        local b_isget = PrivateStateManager:getInstance():GetStateValue(b.bitparam)

        local a_sort = 1
        local b_sort = 1

        if a_condition >= a.count and Utils:get_bit_by_position(a_isget, a.parambit) == 0 then
            a_sort = 0
        elseif a_condition >= a.count and Utils:get_bit_by_position(a_isget, a.parambit) == 1 then
            a_sort = 2
        end

        if b_condition >= b.count and Utils:get_bit_by_position(b_isget, b.parambit) == 0 then
            b_sort = 0
        elseif b_condition >= b.count and Utils:get_bit_by_position(b_isget, b.parambit) == 1 then
            b_sort = 2
        end

        return a_sort < b_sort

    end)


    local get_num = 0
    for i,v in ipairs(config) do
        local condition = PrivateStateManager:getInstance():GetStateValue(v.param)
        local is_get = PrivateStateManager:getInstance():GetStateValue(v.bitparam)
        if condition >= v.count and Utils:get_bit_by_position(is_get, v.parambit) >= 0 then
            get_num = get_num + 1
        end
    end

    self.load_bar:setPercent(get_num / 8 * 100)
    self.num:setString(get_num .. "/8" )

    if get_num == 8 then
        self.num:setTextColor(cc.c3b(0, 255, 0))
    else
        self.num:setTextColor(cc.c3b(255, 0, 0))
    end

    self:updateAwardScroll(config)
end

function XingyaoNode:updateAwardScroll(data)
	local node_list = self.right_scrollview:getChildren()
	if table.nums(node_list) > 0 then
		for key, value in pairs(node_list) do
			value:updateContent(data[key])
		end
	else
		local height = table.nums(data) * 138 >= 535 and table.nums(data) * 138 or 535
		self.right_scrollview:setInnerContainerSize(cc.size(586, height))
		for key, value in pairs(data) do
			local node = XingyaoCell2.new(self)
            node:setTag(key)
			node:setPosition(cc.p(-35, height - key*138) )
			node:updateContent(value)
			self.right_scrollview:addChild(node)
		end
	end
end

function XingyaoNode:updateRed()
	self.red_config = {0,0,0,0,0,0}
    for i,v in ipairs(Quest_titles_config) do
        local condition = PrivateStateManager:getInstance():GetStateValue(v.param)
        local is_get = PrivateStateManager:getInstance():GetStateValue(v.bitparam)
        if condition >= v.count and Utils:get_bit_by_position(is_get,v.parambit) == 0 then
            self.red_config[v.type] = 1
        end
    end

    for i=1,6 do
        local get_num = 0
        for i,v in ipairs(self.info_config[i]) do
            local bit_param = PrivateStateManager:getInstance():GetStateValue(v.bitparam)
            if Utils:get_bit_by_position(bit_param,v.parambit)==1 then
                get_num = get_num + 1
            end
        end
        if get_num == 8 then
            local sum_param = PrivateStateManager:getInstance():GetStateValue(Quest_achievement_config[i].param)
            if Utils:get_bit_by_position(sum_param,Quest_achievement_config[i].parambit) == 0 then
                self.red_config[i] = 1
                self.is_lock[i] = 0
            else
                self.red_config[i] = 0
                self.is_lock[i] = 1
            end
        else
            self.is_lock[i] = 0
        end
    end

    for i,v in ipairs(self.menu_list) do
        if i == 1 then
            if self.red_config[i] == 1 then
                UIBuilder.onAddRedDot(v, true, 112, 31)
            else
                UIBuilder.onAddRedDot(v, false, 112, 31)
            end
        else
            if self.red_config[i] == 1 and self.is_lock[i-1] == 1 then
                UIBuilder.onAddRedDot(v, true, 112, 31)
            else
                UIBuilder.onAddRedDot(v, false, 112, 31)
            end
        end
    end
end

--网络监听(服务器推送消息)
function XingyaoNode:ListenNetWorkMsg(msg_type, msg_data)

end

function XingyaoNode:onTouchCallBack(sender)
	local name = sender:getName()
	if name == "btn_get" then
		local protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_XINGYAO_SECOND)
        protocal.hd_type = self.cur_select_index
        ProtocalPool.SendCMD(NET_ID, protocal)
	end
end

function XingyaoNode:destroy()
	cclog("星耀 node 销毁")
	for key, value in pairs(PrivateStateManager:getInstance().private_state_array) do
		game_app:CancelGameNotify(GameConfig.PRIVATE_STATE_UPDATE_ONE + key, self.privateUpdate)
	end
	self.super.destroy(self)
end

return XingyaoNode