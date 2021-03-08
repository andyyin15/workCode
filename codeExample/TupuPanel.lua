--
--	Author: yhw
--	Date: 2020-08-24
--	灵谱主界面
local DlgBaseWindow = import("...base/DlgBaseWindow")
local TupuPanel = class("TupuPanel",DlgBaseWindow)
	
local TupuLayer = import(".TupuLayer")
local TupuSpecialLayer = import(".TupuSpecialLayer")
local TuringLayer = import(".TuringLayer")
local ZhanhunLayer = import(".ZhanhunLayer")
local PintuLayer = import(".PintuLayer")

local TabNameList = {
	[1] = {index = 1, name = "灵谱", obj = TupuLayer},
	[2] = {index = 2, name = "神谱", obj = TupuSpecialLayer},
	[3] = {index = 3, name = "图灵", obj = TuringLayer},
	[4] = {index = 4, name = "战魂", obj = ZhanhunLayer},
	[5] = {index = 5, name = "拼图", obj = PintuLayer},
}

function TupuPanel:ctor()
	self.super.ctor(self)
    self.lefttablist={}
	self.UI_ID = GameConfig.UI_TUPU_PANEL
	self.name = "TupuPanel"
	self.classDestroy = true
	self.sprits_path = {
		"scripts/UI/Dlg/tupu/TupuMenuCell",
		"scripts/UI/Dlg/tupu/TupuCell",
		"scripts/UI/Dlg/tupu/TupuLayer",
		"scripts/UI/Dlg/tupu/TupuSpecialLayer",
		"scripts/UI/Dlg/tupu/TuringLayer",
		"scripts/UI/Dlg/tupu/ZhanhunLayer",
		"scripts/UI/Dlg/tupu/ZhanhunCell",
		"scripts/UI/Dlg/tupu/ZhanhunMenuCell",
		"scripts/UI/Dlg/tupu/PintuLayer",
	}
	self.res_list = {
		"tupu/Tupu.png",
		"tupu/Tupu.plist",
	}
	self.redFuncList={}--红点状态列表
end

function TupuPanel:create()
	self.super.create(self)

	self.objList = {}

	self.lefttablist = {}
	self:resetMenu()
	for _,v in ipairs(TabNameList) do
		self:addLeftTabButton(v.name,v.index,handler(self, self["tabClick"]),self.lefttablist)
	end
	--self:addLeftTabButton("灵谱", 1, handler(self, self["tabClick"]), self.lefttablist)
	table.insert(self.redFuncList, "tupu")
	--self:addLeftTabButton("神谱", 2, handler(self, self["tabClick"]), self.lefttablist)
	table.insert(self.redFuncList, "teshu")
	--self:addLeftTabButton("图灵", 3, handler(self, self["tabClick"]), self.lefttablist)
	table.insert(self.redFuncList, "tuling")

	table.insert(self.redFuncList, "zhanhun")

	table.insert(self.redFuncList, "pintu")

	self:openClickWindowOutClose()--开启点击窗口以外部分关闭界面
	self:setBlackOpacity(0)--窗口以外的黑色部分半透明值
	--设置标题
	self:setTitleString("灵  谱")
	self:initEvent()
	self:freashRedState()
	return self
end

function TupuPanel:resetMenu()
    local open_day = PrivateStateManager:getInstance():GetRDays()
	if  GGetPlayerAttr( "level" ) >= config_huodongpaixu[431].level and GGetPlayerAttr( "zs_level" ) >= config_huodongpaixu[431].relevel and open_day >=config_huodongpaixu[431].tims and GGetPlayerAttr("vip_level") >= config_huodongpaixu[431].viplevel then
    	TabNameList = {
			[1] = {index = 1, name = "灵谱", obj = TupuLayer},
			[2] = {index = 2, name = "神谱", obj = TupuSpecialLayer},
			[3] = {index = 3, name = "图灵", obj = TuringLayer},
			[4] = {index = 4, name = "战魂", obj = ZhanhunLayer},
			[5] = {index = 5, name = "拼图", obj = PintuLayer},
		}
	else
		TabNameList[5] = nil
	end
end

function TupuPanel:initEvent()
     self.onCheckRed = function( ... )
         self:freashRedState()
     end
     game_app:BindGameNotify(GameConfig.INFO_TUJIAN_RED,self.onCheckRed)
end

function TupuPanel:freashRedState()
	for i=1,#self.lefttablist do
		if self.redFuncList[i] then
			self.lefttablist[i]:getChildByName("red_img"):setVisible(TupuManager:getInstance().redStateList[self.redFuncList[i]])
		end
	end
end

function TupuPanel:showFinishCall()
	self:addContextByCSB("BaseWindowFrame.csb")
	if self.data and self.data.page then
		self:tabClick(self.window:getChildByTag(self.data.page))
	else
		self:tabClick(self.window:getChildByTag(1))
	end
end


function TupuPanel:tabClick(sender)
	if sender:getTag() == 3 then
		local count = TupuManager:getInstance():getCount()
		if count < 30 then
			GShowTipsMsg("只激活了"..count.."张灵谱,要激活了30张灵谱才可开启图灵", 1)
			return
		end
	end

	if self.lastSender then
		self.lastSender:setBright(true)
		self.lastSender.tabNameLabel:setTextColor(cc.c3b(132,122,109))
	end
	self.lastSender = sender

	sender:setBright(false)
	sender.tabNameLabel:setTextColor(cc.c3b(252,233,192))

	self:tabShow(sender:getTag())
end

function TupuPanel:tabShow(index)
	if self.lastIndex == index then return end

	if self.lastIndex and self.objList[self.lastIndex] then
		self.objList[self.lastIndex]:onhide()
	end
	if self.objList[index] == nil then
		self.objList[index] = TabNameList[index].obj:new():create(self)
		self.objList[index].LAYER_ID = index
	end
	self.objList[index]:loadAnsy(function()
		self.objList[index]:show(self.context)
		self.lastIndex = index
		self:hideStopLoad()
	end)
end

---监听网络消息
function TupuPanel:ListenNetWorkMsg(msg_type, msg_data)
	for _,v in pairs(self.objList) do
		if v and v.ListenNetWorkMsg then
			v:ListenNetWorkMsg(msg_type, msg_data)
		end
	end
   
end

--界面刷新
function TupuPanel:Updata(dt)
	for _,v in pairs(self.objList) do
		if v and v.Updata then
			v:Updata(dt)
		end
	end
end

--------销毁界面
function TupuPanel:destroy()
	for i,v in pairs(self.objList) do
		if v and v.destroy then
			v:destroy()
		end
	end
	game_app:CancelGameNotify(GameConfig.INFO_TUJIAN_RED,self.onCheckRed)
	self.super.destroy(self)
end

return TupuPanel