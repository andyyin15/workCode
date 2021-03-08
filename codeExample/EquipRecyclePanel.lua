--Author:yhw
--Date:2020-11-17
--钻石回收
local DlgBaseWindow = import("...base/DlgBaseWindow")
local EquipRecyclePanel = class("EquipRecyclePanel",DlgBaseWindow)
local config_recycle_items=require "scripts/cnf/config_recycle_items"
local config_recycle_suit=require "scripts/cnf/config_recycle_suit"

local ZBRecycleLayer = import(".ZBRecycleLayer")			--装备限时首爆
local TZRecycleLayer = import(".TZRecycleLayer")			--套装显示回收
local DJXSRecycleLayer = import(".DJXSRecycleLayer")		--单件限时回收
local SSRecycleLayer = import(".SSRecycleLayer")			--BOSS首杀
local ZBRecycleForever = import(".ZBRecycleForever")		--装备永久回收
local RecordRecycleLayer = import(".RecordRecycleLayer")	--回收记录
local DiamondRecyleLayer = import(".DiamondRecyleLayer")    --钻石记录
local HSLBLayer = import(".HSLBLayer")    --钻石记录

function EquipRecyclePanel:ctor()
	self.super.ctor(self)
	self.UI_ID = GameConfig.UI_EQUIPRECYCLE_PANEL
	self.name = "EquipRecyclePanel"
	self.classDestroy=true
	self.redFuncList = {} --红点函数列表

	self.res_list = {
		
	}
	self.sprits_path = {
		"scripts/UI/Dlg/equipRecycle/ZBRecycleLayer",
		"scripts/UI/Dlg/equipRecycle/TZRecycleLayer",
		"scripts/UI/Dlg/equipRecycle/DJXSRecycleLayer",
		"scripts/UI/Dlg/equipRecycle/SSRecycleLayer",
		"scripts/UI/Dlg/equipRecycle/RecordRecycleLayer",
		"scripts/UI/Dlg/equipRecycle/ZBRecycleForever",
		"scripts/UI/Dlg/equipRecycle/DiamondRecyleLayer",
		"scripts/UI/Dlg/equipRecycle/HSLBLayer",
	}
end

function EquipRecyclePanel:create()
	self.super.create(self)
	self.lefttablist={}
	self:setTitleString("钻石回收")--窗口标题
	self.list={}


	self:openClickWindowOutClose()--开启点击窗口以外部分关闭界面
	self:setBlackOpacity(0)--窗口以外的黑色部分半透明值

	return self
end

function EquipRecyclePanel:showFinishCall( )
	self.super.showFinishCall(self)

	local protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_RECYCLE_ALL_INFO)
	ProtocalPool.SendCMD(NET_ID,protocal)

	self.equipRecycleLayer = self:addContextByCSB("equipRecycle/EquipRecyclePanel.csb")
	self.menuListView = self:seekNode("menu_listview", self.equipRecycleLayer)
	self.menuListView:setScrollBarEnabled(false)
	self.menuListView:setItemsMargin(5)
	self.menuCell = self:seekNode("menu_cell", self.equipRecycleLayer)
	self.contentLayer = self:seekNode("content_layer", self.equipRecycleLayer)
	self:_initMenu()
	self:freshRedState()
	self:initEvent()
	if self.data and self.data.page then
		for i,v in ipairs(self.menuDataList) do
			if self.data.page == v.page then
				self:_menuCallback(i)
				break
			end
		end
	else
		self:_menuCallback(1)
	end
end

function EquipRecyclePanel:freshRedState()
	local openday =PrivateStateManager.getInstance():GetRDays()--开服天数
    local hfday =PrivateStateManager.getInstance():GetUDays()--合服天数
	if openday <= 7 then-- or (hfday~=0 and hfday <=7 )
		if self.redFuncList[1] then
			self.list[2]:setVisible(EquipRecycleRedMgr:getInstance().redStateList["DJXS"])
		end
		if self.redFuncList[2] then
			self.list[3]:setVisible(EquipRecycleRedMgr:getInstance().redStateList["TZ"])
		end
		if self.redFuncList[3] then
			self.list[4]:setVisible(EquipRecycleRedMgr:getInstance().redStateList["ZBForever"])
		end
		if self.redFuncList[4] then
			self.list[5]:setVisible(EquipRecycleRedMgr:getInstance().redStateList["MQForever"])
		end
	else
		if self.redFuncList[1] then
			self.list[2]:setVisible(EquipRecycleRedMgr:getInstance().redStateList["ZBForever"])
		end
		if self.redFuncList[2] then
			self.list[3]:setVisible(EquipRecycleRedMgr:getInstance().redStateList["MQForever"])
		end
	end
	
end

function EquipRecyclePanel:_initMenu()
	self:SendCMD(ProtocalCode.PT_RECYCLE_ALL_INFO)
	self.menuDataList = {}

	local openday =PrivateStateManager.getInstance():GetRDays()--开服天数
    local hfday =PrivateStateManager.getInstance():GetUDays()--合服天数
    local award_status = PrivateStateManager:getInstance():GetStateValue(2199) or 0

	table.insert(self.menuDataList, {name = "钻石福利", class = DiamondRecyleLayer, page = 1})
    if openday <= 7 then-- or (hfday~=0 and hfday <=7 )
		table.insert(self.menuDataList, {name = "装备首爆限时", class = ZBRecycleLayer, page = 2})
		table.insert(self.redFuncList, "DJXS")
    	table.insert(self.menuDataList, {name = "套装回收限时", class = TZRecycleLayer, page = 4})
		table.insert(self.redFuncList, "TZ")
	end
    table.insert(self.menuDataList, {name = "装备回收永久", class = ZBRecycleForever, page = 5})
	table.insert(self.redFuncList, "ZBForever")

	table.insert(self.menuDataList, {name = "特殊装备回收", class = DJXSRecycleLayer, page = 3})
	table.insert(self.redFuncList, "MQForever")

    if openday <= 7 then
		table.insert(self.menuDataList, {name = "BOSS首杀", class = SSRecycleLayer, page = 6})
	end
	table.insert(self.menuDataList, {name = "回收记录", class = RecordRecycleLayer, page = 7})
	if openday >= 8 and Utils:get_bit_by_position(award_status, 3) == 0 then
		table.insert(self.menuDataList, {name = "钻石回收特权", class = HSLBLayer, page = 8})
	end
	

	self.menuBtnList = {}
    for i,v in ipairs(self.menuDataList) do
    	local cell = self.menuCell:clone()
    	cell:setVisible(true)
    	local btn = cell:getChildByName("cell_btn")
    	local redPoint = cell:getChildByName("cell_red")
    	self.list[i]=redPoint
    	btn:setTitleText(v.name)
    	btn:setTitleColor(cc.c3b(0x68,0x56,0x3e))
		btn:addClickEventListener(function()
			self:_menuCallback(i)
		end)
		table.insert(self.menuBtnList, btn)
		self.menuListView:pushBackCustomItem(cell)
    end
end

function EquipRecyclePanel:initEvent()
	self.onCheckRed = function()
		self:freshRedState()
	end

	game_app:BindGameNotify(GameConfig.NOTIFY_EQUIPRECYCLE_RED_INFO, self.onCheckRed)
end

function EquipRecyclePanel:_menuCallback(index)
	if self.lastIndex == index then
		return 
	end
	if self.lastIndex then
		self.menuBtnList[self.lastIndex]:setTitleColor(cc.c3b(0x68,0x56,0x3e))
		self.menuBtnList[self.lastIndex]:setBright(true)
	end
	self.menuBtnList[index]:setTitleColor(cc.c3b(0xeb,0xde,0xba))
	self.menuBtnList[index]:setBright(false)
	self.lastIndex = index

	self:_refreshPage(index)
end

function EquipRecyclePanel:_refreshPage(index)
	if self.curPage and self.curPage.destroy then
		self.curPage:destroy()
		self.curPage = nil
	end

	self.curPage = self.menuDataList[index].class:new():create(self)
	self.curPage.LAYER_ID = index
	self.curPage:loadAnsy(function()
		self.curPage:show(self.contentLayer)
		self:hideStopLoad()
	end)
end

---监听网络消息
function EquipRecyclePanel:ListenNetWorkMsg(msg_type, msg_data)
	if self.curPage and self.curPage.ListenNetWorkMsg then
		self.curPage:ListenNetWorkMsg(msg_type, msg_data)
	end
end
--界面刷新
function EquipRecyclePanel:Updata(dt)
	if self.curPage and self.curPage.Updata then
		self.curPage:Updata(dt)
	end
end
--------销毁界面
function EquipRecyclePanel:destroy()
	if self.curPage and self.curPage:destroy() then
		self.curPage:destroy()
	end
	game_app:CancelGameNotify(GameConfig.NOTIFY_EQUIPRECYCLE_RED_INFO, self.onCheckRed)
	self.super.destroy(self)
end

return EquipRecyclePanel