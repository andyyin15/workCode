--
--	Author: yhw
--	Date: 2020-09-06
--	神翼主页面
local DlgBaseWindow = import("...base/DlgBaseWindow")
local WingMainPanel = class("WingMainPanel", DlgBaseWindow)

local WingAdvanceLayer = import(".WingAdvanceLayer")
local WingEquipLayer = import(".WingEquipLayer")
local WingResolveLayer = import(".WingResolveLayer")

local TabNameList = {
	[1] = {index = 1, name = "升阶", obj = WingAdvanceLayer},
	[2] = {index = 2, name = "装备", obj = WingEquipLayer},
	[3] = {index = 3, name = "分解", obj = WingResolveLayer},
}

function WingMainPanel:ctor()
	self.super.ctor(self)
	self.UI_ID = GameConfig.UI_WING_PANEL
	self.name = "WingMainPanel"
	self.classDestroy = true
	self.sprits_path = {
		"scripts/UI/Dlg/wing/WingGiftLayer",
		"scripts/UI/Dlg/wing/WingAdvanceLayer",
		"scripts/UI/Dlg/wing/WingEquipNode",
		"scripts/UI/Dlg/wing/WingSuitTipsLayer",
		"scripts/UI/Dlg/wing/WingEquipLayer",
		"scripts/UI/Dlg/wing/WingResolveLayer",
	}
	self.res_list = {
		
	}
end

function WingMainPanel:create()
	self.super.create(self)

	self.lefttablist = {}
	for _,v in ipairs(TabNameList) do
		self:addLeftTabButton(v.name,v.index,handler(self, self["tabClick"]),self.lefttablist)
	end
	self:openClickWindowOutClose()--开启点击窗口以外部分关闭界面
	self:setBlackOpacity(0)--窗口以外的黑色部分半透明值
	--设置标题
    self:setTitleString("神  翼")
    self:initEvent()

	return self
end

function WingMainPanel:initEvent()
    self.onUpdateRed = function ()
        self:updateRed()
    end
    game_app:BindGameNotify(GameConfig.NOTIFY_WING_RED_INFO, self.onUpdateRed)
end


-- 刷新红点
function WingMainPanel:updateRed()
    local redList = WingManager:getInstance().redList
    self.lefttablist[1]:getChildByName("red_img"):setVisible(redList["wing"])
    -- UIBuilder.onAddRedDot(self.lefttablist[1], redList['wing'], 25, 50)       -- 神翼升阶
    self.lefttablist[2]:getChildByName("red_img"):setVisible(redList["zhuangbei"])
    self.lefttablist[3]:getChildByName("red_img"):setVisible(redList["fenjie"])
end

function WingMainPanel:showFinishCall()
	if self.data and self.data.page then
		self:tabClick(self.window:getChildByTag(self.data.page))
	else
		self:tabClick(self.window:getChildByTag(1))
    end
    
    self:updateRed()
end

function WingMainPanel:tabClick(sender)
	if self.lastSender then
		self.lastSender:setBright(true)
		self.lastSender.tabNameLabel:setTextColor(cc.c3b(132,122,109))
	end
	self.lastSender = sender

	sender:setBright(false)
	sender.tabNameLabel:setTextColor(cc.c3b(252,233,192))

	self:tabShow(sender:getTag())
end

function WingMainPanel:tabShow(index)
	if self.lastIndex == index then return end

	if self.curPage and self.curPage.destroy then
		self.curPage:destroy()
		self.curPage = nil
	end

	if TabNameList[index].obj then 
		self.curPage = TabNameList[index].obj:new():create()
		self.curPage.LAYER_ID = index
		self.curPage:loadAnsy(function()
			self.curPage:show(self.context)
			self:hideStopLoad()
		end)
	end
	self.lastIndex = index
end

---监听网络消息
function WingMainPanel:ListenNetWorkMsg(msg_type, msg_data)
	if self.curPage and self.curPage.ListenNetWorkMsg then
		self.curPage:ListenNetWorkMsg(msg_type, msg_data)
	end
end

--界面刷新
function WingMainPanel:Updata(dt)
	if self.curPage and self.curPage.Updata then
		self.curPage:Updata(dt)
	end
end

--------销毁界面
function WingMainPanel:destroy()
    game_app:CancelGameNotify(GameConfig.NOTIFY_WING_RED_INFO, self.onUpdateRed)

	if self.curPage and self.curPage.destroy then
		self.curPage:destroy()
		self.curPage = nil
	end
	self.super.destroy(self)
end

function WingMainPanel:setUI(data)
	if data and data.page then
		self:tabClick(self.window:getChildByTag(data.page))
	end
end

return WingMainPanel