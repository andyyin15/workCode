
--
--author yhw
--date 2021/1/20
--渡劫
local UILayerbase = import("...base/UILayerbase")
local DujiePanel = class("DujiePanel",UILayerbase)
local OtherBuyPanel = require "scripts/UI/Dlg/main/OtherBuyPanel"
local Rolemodel                = require "scripts/UI/Dlg/role/RoleModelAction"

require "scripts/cnf/new_feisheng_config"
require "scripts/cnf/reincarnation_config"
require "scripts/cnf/feisheng_deco_config"

local EquipPageTitles =
{
    imgDic = "Role_Role1",
    { [1] = "nimg_feisheng_6.png", [2] = "nimg_feisheng_7.png" },
    { [1] = "nimg_feisheng_5.png", [2] = "nimg_feisheng_0.png" }, 
    { [1] = "nimg_feisheng_4.png", [2] = "nimg_feisheng_3.png" }, 
    { [1] = "nimg_feisheng_1.png", [2] = "nimg_feisheng_2.png" }, 
}

local figureList =
{
    [1] = "renwu_1.png", 
    [2] = "renwu_2.png", 
    [3] = "renwu_3.png", 
    [4] = "renwu_4.png", 
}

local equip_index_list={
                        8,0,43,44,9,14,16,1,2,15,17,3,4,28,12,5,7,6,27,25,26,29,984,
                        973,974,975,976,977,978,979,980,981,982,2377,
                        2264,2265,2266,2267,2268,2269,
                        2271,2272,2273,2274,2275,2276,
                        2278,2279,2280,2281,2282,2283,
                        2285,2286,2287,2288,2289,2290,
                        2248,2249,2250,2251,2252,2253,
                       }

local SlotPage1 = NewConst({ --遗忘装备
    -- 第一行
    [2301+1]  = {r = 1, c = 1, p = 1}, -- 散仙剑
    [2303+1]  = {r = 1, c = 2, p = 1}, -- 散仙甲

    -- 第二行
    [2302+1]   = {r = 2, c = 1, p = 1}, -- 散仙冠
    [2304+1] = {r = 2, c = 2, p = 1}, -- 散仙珠

    -- 第三行
    [2305+1]   = {r = 3, c = 1, p = 1}, -- 散仙玉
    [2306+1] = {r = 3, c = 2, p = 1}, -- 散仙石

    -- 第四行
    [2307+1]   = {r = 4, c = 1, p = 1}, -- 散仙鞋
    [2308+1] = {r = 4, c = 2, p = 1}, -- 散仙鞋
})

local SlotPage2 = NewConst({
    -- 第一行
    [2316+1]  = {r = 1, c = 1, p = 2}, -- 真仙剑
    [2318+1]  = {r = 1, c = 2, p = 2}, -- 真仙甲

    -- 第二行
    [2317+1]   = {r = 2, c = 1, p = 2}, -- 真仙冠
    [2319+1] = {r = 2, c = 2, p = 2}, -- 真仙珠

    -- 第三行
    [2320+1]   = {r = 3, c = 1, p = 2}, -- 真仙玉
    [2321+1] = {r = 3, c = 2, p = 2}, -- 真仙石

    -- 第四行
    [2322+1]   = {r = 4, c = 1, p = 2}, -- 真仙鞋
    [2323+1] = {r = 4, c = 2, p = 2}, -- 真仙鞋
})

local SlotPage3 = NewConst({
    -- 第一行
    [2331+1]  = {r = 1, c = 1, p = 3}, -- 金仙剑
    [2333+1]  = {r = 1, c = 2, p = 3}, -- 金仙甲

    -- 第二行
    [2332+1]   = {r = 2, c = 1, p = 3}, -- 金仙冠
    [2334+1] = {r = 2, c = 2, p = 3}, -- 金仙珠

    -- 第三行
    [2335+1]   = {r = 3, c = 1, p = 3}, -- 金仙玉
    [2336+1] = {r = 3, c = 2, p = 3}, -- 金仙石

    -- 第四行
    [2337+1]   = {r = 4, c = 1, p = 3}, -- 金仙鞋
    [2338+1] = {r = 4, c = 2, p = 3}, -- 金仙鞋
})

local SlotPage4 = NewConst({
    -- 第一行
    [2346+1]  = {r = 1, c = 1, p = 4}, -- 太乙剑
    [2348+1]  = {r = 1, c = 2, p = 4}, -- 太乙甲

    -- 第二行
    [2347+1]   = {r = 2, c = 1, p = 4}, -- 太乙冠
    [2349+1] = {r = 2, c = 2, p = 4}, -- 太乙珠

    -- 第三行
    [2350+1]   = {r = 3, c = 1, p = 4}, -- 太乙玉
    [2351+1] = {r = 3, c = 2, p = 4}, -- 太乙石

    -- 第四行
    [2352+1]   = {r = 4, c = 1, p = 4}, -- 太乙鞋
    [2353+1] = {r = 4, c = 2, p = 4}, -- 太乙鞋
})

---部位所在的位置---
local EquipIndexArea = NewConst({
    [2301+1] = ItemType.SANXIAN161 ,    -- 散仙剑
    [2302+1] = ItemType.SANXIAN162 ,    -- 散仙甲
    [2303+1] = ItemType.SANXIAN163 ,    -- 散仙冠
    [2304+1] = ItemType.SANXIAN164 ,    -- 散仙珠
    [2305+1] = ItemType.SANXIAN165 ,    -- 散仙玉
    [2306+1] = ItemType.SANXIAN166 ,    -- 散仙石
    [2307+1] = ItemType.SANXIAN167 ,    -- 散仙鞋
    [2308+1] = ItemType.SANXIAN168 ,    -- 散仙腰

    [2316+1] = ItemType.ZHENXIAN169 ,    -- 真仙剑
    [2317+1] = ItemType.ZHENXIAN170 ,    -- 真仙甲
    [2318+1] = ItemType.ZHENXIAN171 ,    -- 真仙冠
    [2319+1] = ItemType.ZHENXIAN172 ,    -- 真仙珠
    [2320+1] = ItemType.ZHENXIAN173 ,    -- 真仙玉
    [2321+1] = ItemType.ZHENXIAN174 ,    -- 真仙石
    [2322+1] = ItemType.ZHENXIAN175 ,    -- 真仙鞋
    [2323+1] = ItemType.ZHENXIAN176 ,    -- 真仙腰

    [2331+1] = ItemType.JINXIAN177 ,    -- 金仙剑
    [2332+1] = ItemType.JINXIAN178 ,    -- 金仙甲
    [2333+1] = ItemType.JINXIAN179 ,    -- 金仙冠
    [2334+1] = ItemType.JINXIAN180 ,    -- 金仙珠
    [2335+1] = ItemType.JINXIAN181 ,    -- 金仙玉
    [2336+1] = ItemType.JINXIAN182 ,    -- 金仙石
    [2337+1] = ItemType.JINXIAN183 ,    -- 金仙鞋
    [2338+1] = ItemType.JINXIAN184 ,    -- 金仙腰

    [2346+1] = ItemType.TAIYI185 ,    -- 太乙剑
    [2347+1] = ItemType.TAIYI186 ,    -- 太乙甲
    [2348+1] = ItemType.TAIYI187 ,    -- 太乙冠
    [2349+1] = ItemType.TAIYI188 ,    -- 太乙珠
    [2350+1] = ItemType.TAIYI189 ,    -- 太乙玉
    [2351+1] = ItemType.TAIYI190 ,    -- 太乙石
    [2352+1] = ItemType.TAIYI191 ,    -- 太乙鞋
    [2353+1] = ItemType.TAIYI192 ,    -- 太乙腰
})

local jie_name = {[1] = "一",[2] = "二",[3] = "三",[4] = "四",[5] = "五",[6] = "六",[7] = "七",[8] = "八",[9] = "九",[10] = "十",[11] = "十一",[12] = "十二",[13] = "十三",[14] = "十四",[15] = "十五",}

function DujiePanel:ctor()
    self.super.ctor(self)
    --self.UI_ID = 999
    self.name = "DujiePanel"
    self.csbfile = "role/zhuansheng/DujiePanel.csb";
end

function DujiePanel:create( _parent )
    self.super.create(self)
    self.game_layer = self:seekNode("game_layer")

    -- self.role_model_panel = self:seekNode("role_model_panel")
    -- self.role_Model=Rolemodel:create()
    -- self.role_model_panel:addChild(self.role_Model)
    
    self.dj_level = PrivateStateManager.getInstance():GetStateValue(1045) --渡劫等级
    self.data_array = feisheng_deco_config
    self.curPage = 1
    self.pageList = {}

    self.curItemList = {}
    self.parent      = _parent
    self:bindNetInfo()
    self:SetCreateItem()
    --self:updateRoleModelEx()
    self:CheckSelectBtn()
    self.totalExp = 0
    return self
end

function DujiePanel:SetCreateItem()
    self.equipListNode  = self.game_layer:getChildByName("equipListNode")
    self.info_layer = self.game_layer:getChildByName("right_layer_1")
    self.infobag_layer = self.game_layer:getChildByName("right_layer_2")
    self.left_layer = self.game_layer:getChildByName("left_layer")

    self.role_base_btn=self:seekNode("role_base_btn")
    self.role_other_btn=self:seekNode("role_other_btn")
    
    self.info_btn = self.info_layer:getChildByName("info_btn")
    self.info_btn_1 = self.infobag_layer:getChildByName("info_btn_1")

    self.power = self:seekNode("power")
    self.lvname = self:seekNode("name")
    self.shuxingTxt = self:seekNode("shuxingTxt")
    self.exp_lab = self:seekNode("exp_lab_0")
    self.exp_btn = self:seekNode("exp_btn")
    self.exp_btn:addClickEventListener(handler(self,self.onGetexpWay))
    self.need_level = self:seekNode("infoTxt")
    self.sj_btn = self:seekNode("go_btn")
    self.ProgressBar = self:seekNode("bar")
    self.eat_btn = self:seekNode("eat_btn")

    self.attTxt_1 = self:seekNode("attTxt_1")
    self.attTxt_2 = self:seekNode("attTxt_2")
    self.attTxt_3 = self:seekNode("attTxt_3")
    self.attTxt_4 = self:seekNode("attTxt_4")
    self.d_val1 = self:seekNode("att_1_0")
    self.d_val2 = self:seekNode("att_2_0")
    self.d_val3 = self:seekNode("att_3_0")
    self.d_val4 = self:seekNode("att_4_0")

    self.attTxt_1_0 = self:seekNode("attTxt_1_0")
    self.attTxt_2_0 = self:seekNode("attTxt_2_0")
    self.attTxt_3_0 = self:seekNode("attTxt_3_0")
    self.attTxt_4_0 = self:seekNode("attTxt_4_0")
    self.u_val1 = self:seekNode("att_1")
    self.u_val2 = self:seekNode("att_2")
    self.u_val3 = self:seekNode("att_3")
    self.u_val4 = self:seekNode("att_4")

    self.attTxt_1:setString("生    命:")
    self.attTxt_1_0:setString("生    命:")
    self.attTxt_2:setString("攻    击:")
    self.attTxt_2_0:setString("攻    击:")

    self.value_txt = self:seekNode("value_txt")

    self.enter_btn = self:seekNode("enter_btn")
    self.model = self.left_layer:getChildByName('model')

    self.figure = self.left_layer:getChildByName('figure')

    self.effect=UIBuilder.CreateEffect(1087,182,10,self.ProgressBar,1/12,true,false)

    local effct_id = UIBuilder.CreateEffect(1150,self.sj_btn:getContentSize().width/2-3,self.sj_btn:getContentSize().height/2-3,self.sj_btn,1/12,true,false)
    self.sj_btn.effct_id=effct_id
    self.sj_btn.effct_id:setVisible(false)

    -- self.roleEff = self:createEffect(1163, self.model, 0, -40)

    for i=1,4 do
        self["select_btn_"..i] = self.equipListNode:getChildByName("select_btn_"..i)
        self["select_btn_"..i]:addTouchEventListener(handler(self,self.onTouchCallBack))
    end

    self.cellPages={}
    for i=1,4 do
        self:CreateItemsPage(i)
    end

    local infobtnTips_1 = function ()
        local tips = UIBuilder.createComponent("PublicTipsPanel", GameConfig.helpTips[60].des)
        self.parent:addChild(tips)
    end
    local infobtnTips_2 = function ()
        local tips = UIBuilder.createComponent("PublicTipsPanel", GameConfig.helpTips[60].des)
        self.parent:addChild(tips)
    end
    self.info_btn:addClickEventListener(infobtnTips_1)
    self.info_btn_1:addClickEventListener(infobtnTips_2)

    local onBtnCallback2 = function ( ... )--eventId, midX, midY)
        self:SelectView(2)
    end
    self.role_other_btn:addClickEventListener(onBtnCallback2)

    local onBtnCallback3 = function ( ... )--eventId, midX, midY)
        self:UpdateInfo()
        self:SelectView(1)
    end
    self.role_base_btn:addClickEventListener(onBtnCallback3)
    
    self:Refresh()
    self:createBagBox()
    self:UpdateInfo()
    self:BindHandle()
    self:updateBagBox( )
end

--创建动画
function DujiePanel:createEffect(effectId, node, x, y)
    local posx = x or 0
    local posy = y or 0
    local effect = UIBuilder.CreateEffect(effectId, posx, posy, node, nil, true, false)
    return effect
end

function DujiePanel:onGetexpWay()
    -- if GGetPlayerAttr("zs_level") >= 14 then
        -- GApproachToAccess(2114)
        -- GameUIManager:destroy_window(GameConfig.UI_ROLE_PANEL)
        -- else
        --     GShowTipsMsg('转生30转才可以购买商品！')
        -- end
        if not self.OtherBuyPanel then
            self.OtherBuyPanel = OtherBuyPanel:new():create(self)
            self.OtherBuyPanel:showLeftContent(22)
            self.OtherBuyPanel:setLocalZOrder(-1)
            GameWorld.Layer:get_layer_info():addChild(self.OtherBuyPanel)
            self.OtherBuyPanel:setPosition(SCREEN_SIZE.width/2,SCREEN_SIZE.height/2)
        else
            self.OtherBuyPanel:setVisible(true)
            self.OtherBuyPanel:showLeftContent(22)
        end
    end

function DujiePanel:CheckSelectBtn()
    self.select_btn_2:setVisible(false)
    self.select_btn_3:setVisible(false)
    self.select_btn_4:setVisible(false)

    local select_sort = 0
    local btnStatelist = {true,false,false,false}

    for i=2317,2324 do
        if game_app.itemManager.equipList[i] then
            self.select_btn_2:setVisible(true)
            select_sort = select_sort + 1
            btnStatelist[2] = true
            break
        end
    end

    for i=2332,2339 do
        if game_app.itemManager.equipList[i] then
            self.select_btn_3:setVisible(true)
            select_sort = select_sort + 1
            btnStatelist[3] = true
            break
        end
    end

    for i=2347,2354 do
        if game_app.itemManager.equipList[i] then
            self.select_btn_4:setVisible(true)
            select_sort = select_sort + 1
            btnStatelist[4] = true
            break
        end
    end
    local count = 0
    for i,v in ipairs(btnStatelist) do
        if v then
            count = count + 1
            self["select_btn_"..i]:setPosition(120+(count*100)+(-50*(select_sort-1)), -48)
        end
    end

    -- for i=1,4 do
    --     self["select_btn_"..i]:setPosition(120+(i*100)+(-50*(select_sort-1)), -48)
    -- end

    self.imgSelect = self.equipListNode:getChildByName("img_select")

    self.btnPoses = {}
    self.btnPoses[1] = cc.p( self.select_btn_1:getPosition() )
    self.btnPoses[2] = cc.p( self.select_btn_2:getPosition() )
    self.btnPoses[3] = cc.p( self.select_btn_3:getPosition() )
    self.btnPoses[4] = cc.p( self.select_btn_4:getPosition() )

    self.imgSelect:setPosition( self.btnPoses[1] )
    --self.equipListNode:setPosition(842-175+select_sort*50,333)
end

function DujiePanel:UpdateInfo()
    local privateManager = PrivateStateManager.getInstance()
    local level=privateManager:GetStateValue(1053)  --1053飞升等级 
    local exp=privateManager:GetStateValue(1054)  --1054飞升经验值
    -- local zhuansheng_data = reincarnation_config[#reincarnation_config]
    self.level_info=new_feisheng_config[level] or new_feisheng_config[1]
    self.next_level_info=new_feisheng_config[level+1] or new_feisheng_config[level]
    self.power:setString(self.level_info.zhanli )--+ zhuansheng_data.zhanli
    local jie_level = math.ceil(level/10)
    
    if level == 0 then
        self.lvname:setString("未激活")
    else
        self.lvname:setString(jie_name[jie_level].."阶  "..self.level_info.name)
    end
    self.shuxingTxt:setVisible(false)
    --self.shuxingTxt:setString(string.format("转生属性：攻击增加%s%%",zhuansheng_data.Attackaddition/100))
    if level==0 then
        self.power:setString(0)
    end

    self.exp_lab:setString(string.format("%d/%d",exp,self.next_level_info.feisheng_exp))
   
    self.need_level:setVisible(self.dj_level<self.next_level_info.class)
    if self.dj_level<self.next_level_info.class then
        self.sj_btn:setTitleText("考  试")
    else
        self.sj_btn:setTitleText("升  学")
    end
    self.sj_btn.effct_id:setVisible(false)

    self.ProgressBar:setPercent(exp/self.next_level_info.feisheng_exp*100)

    self.effect:setVisible(exp >= self.next_level_info.feisheng_exp)

    if level==0 then
        self.u_val1:setString("0")
        self.u_val2:setString("0-0")
        self.u_val3:setString("0-0")
        self.u_val4:setString("0-0")

        self.d_val1:setString(self.next_level_info.left)
        self.d_val2:setString(self.next_level_info.attack_min.."-"..self.next_level_info.attack_max)
        self.d_val3:setString(self.next_level_info.defence_min.."-"..self.next_level_info.defence_max)
        self.d_val4:setString(self.next_level_info.fei_attack_min.."-"..self.next_level_info.fei_attack_max)
        self.need_level:setString(string.format("完成%d阶考试可升级",self.next_level_info.class))
        if exp<self.next_level_info.feisheng_exp then
            self.sj_btn.effct_id:setVisible(false)
        else
            self.sj_btn.effct_id:setVisible(true)
        end
    elseif level>0 and level<#new_feisheng_config then
        self.d_val1:setString(self.next_level_info.left)
        self.d_val2:setString(self.next_level_info.attack_min.."-"..self.next_level_info.attack_max)
        self.d_val3:setString(self.next_level_info.defence_min.."-"..self.next_level_info.defence_max)
        self.d_val4:setString(self.next_level_info.fei_attack_min.."-"..self.next_level_info.fei_attack_max)

        self.u_val1:setString(self.level_info.left)
        self.u_val2:setString(self.level_info.attack_min.."-"..self.level_info.attack_max)
        self.u_val3:setString(self.level_info.defence_min.."-"..self.level_info.defence_max)
        self.u_val4:setString(self.level_info.fei_attack_min.."-"..self.level_info.fei_attack_max)

        self.need_level:setString(string.format("完成%d阶考试可升级",self.next_level_info.class))
        if exp<self.next_level_info.feisheng_exp then
            self.sj_btn.effct_id:setVisible(false)
        else
            self.sj_btn.effct_id:setVisible(true)
        end
    elseif level==#new_feisheng_config then
        self.sj_btn:setTitleText("满  级")
        self.u_val1:setString(self.level_info.left)
        self.u_val2:setString(self.level_info.attack_min.."-"..self.level_info.attack_max)
        self.u_val3:setString(self.level_info.defence_min.."-"..self.level_info.defence_max)
        self.u_val4:setString(self.level_info.fei_attack_min.."-"..self.level_info.fei_attack_max)
        -- for k,v in pairs(self.pos_list) do
        --     v:SetVisible(true)
        -- end
        self.sj_btn.effct_id:setVisible(false)
        self.need_level:setVisible(false)
        self.ProgressBar:setPercent(exp/self.next_level_info.feisheng_exp*100)
        self.exp:setString(string.format("知识储备：满级"))
    end     

end

function DujiePanel:updateRoleModelEx(  )
    if self.role_Model then
        self.role_Model:setHair()  -- 头发
        self.role_Model:setHat()   -- 面具
        self.role_Model:setCloth() -- 衣服
    end
end

function DujiePanel:bindNetInfo()
     self.updateNet = function ()
        self:UpdateInfo()  
    end
    game_app:BindGameNotify(GameConfig.NOTIFY_ROLE_INFO,self.updateNet) 

    self.updateChangeItem = function(data)
        if data.itemList[1].state == 0 then
            self:updateBagBox()
        end
    end
    game_app:BindGameNotify( GameConfig.NOTIFY_ITEM_CHANGE , self.updateChangeItem )

    self.refreshHandler = handler( self , self.Refresh )
    game_app:BindGameNotify( GameConfig.NOTIFY_ITEM_CHANGE,  self.refreshHandler )
end

function DujiePanel:BindHandle()
    local function Ontupo_btn()
        -- if GGetPlayerAttr("zs_level") >= 30 then
            if not self.next_level_info then return end
            if self.dj_level<self.next_level_info.class then
                local DujieBuyPanel=require "scripts/UI/Dlg/role/DujieBuyPanel"
                local dujieBuyPanel = DujieBuyPanel:create()
                self.parent:addChild(dujieBuyPanel)
            else
                local  protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_DUJIE_GO_OR_UP)
                protocal.atype = 2
                protocal.aid = 1
                ProtocalPool.SendCMD(NET_ID, protocal)

            end
        -- else
        --     GShowTipsMsg('转生30转才可以开始考试！')
        -- end
    end
    self.sj_btn:addClickEventListener(Ontupo_btn)

    local function OnEnterBtn()
        -- if GGetPlayerAttr("zs_level") >= 30 then
            local  protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_DUJIE_GO_OR_UP)
            protocal.atype = 4
            ProtocalPool.SendCMD(NET_ID, protocal)
            GameUIManager:destroy_window(GameConfig.UI_ROLE_PANEL)
        -- else
        --     GShowTipsMsg('转生30转才可以进入！')
        -- end
    end
    self.enter_btn:addClickEventListener(OnEnterBtn)

    local function OnTunShiBtn()
        -- if GGetPlayerAttr("zs_level") >= 30 then
            if self.curItem then
                local  protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_DUJIE_GO_OR_UP)
                protocal.atype = 3
                protocal.aid = self.curItem.entry_id
                ProtocalPool.SendCMD(NET_ID, protocal)
            else
                game_app:SendGameNotify(GameConfig.NOTIFY_INFO, '请选择要吞噬的装备!')
            end
        -- else
        --     GShowTipsMsg('转生30转才可以吞噬！')
        -- end
    end
   self.eat_btn:addClickEventListener(OnTunShiBtn)

    local function OnUnloadEquipment(data)
        --self:Refresh()
        local info_string_list =
        {
            [0] = "卸载装备成功",
            [1] = "背包不足，卸载装备失败",
            [2] = "该装备无法脱落",--"找不到该装备，卸载装备失败",
            [3] = "该装备无法脱落"
        }
        local info_str = info_string_list[data.result]
        if info_str then
            game_app:SendGameNotify(GameConfig.NOTIFY_INFO, info_str)
        end
    end
    NetWorkHandleMsg.BindMsgHandle(self, OnUnloadEquipment, ProtocalCode.PT_Unload_Equipment)
end

function DujiePanel:createBagBox(  )
    self.page_bag = self.infobag_layer:getChildByName("page_bag")
    self.bagBoxPage = UIBuilder.CreateUIBoxPageView(10,135,4,4,12,12,handler(self,self["cellTouchEventToBag"]),true,self.infobag_layer)
    self.bagBoxPage:createPageView(16)
    self.boxPageTip = UIBuilder.CreateUIPageTip(987,125,30,1, self.infobag_layer )
end

function DujiePanel:cellTouchEventToBag( event )
    if event.item then
        -- if self.selectBagCell == event.target then
        --     return
        -- end
        self:setSelectItem(event.target)
    end
end

function DujiePanel:getItemList( )
    local bagList = game_app.itemManager.bagList
    local list = {}
    for k,v in pairs( bagList ) do
        local item_data = GGetItemDataById( v.entry_id)
        if self:isCanDevour(v) then
            table.insert(list,v)
        end
    end
    return list
end

function DujiePanel:updateBagBox( isReset )
    --self.curItemList = {}
    local bagList = self:getItemList( )
    local len = #bagList == 0 and 1 or #bagList
    self.bagBoxPage:createPageView( len )
    self.bagBoxPage:setNodeData( bagList )
    if #bagList > 0 then
        local cell = self.bagBoxPage:getItemCellByIndex( 1 )
        self:setSelectItem( cell )
    else
        self.curItem = nil
        self.value_txt:setString("吞噬后可获得知识储备："..0)
    end
    --self.bagBoxPage:setEventCallBack(handler(self,self["cellTouchEventToBag"]))  
end

function DujiePanel:setSelectItem(cell)
    if cell and cell.item then
        if self.selectBagCell then
            self.selectBagCell:setImgSelect(false)
        end
        self.selectBagCell = cell
        self.selectBagCell:setImgSelect(true)
        self.curItem = cell.item
        --Utils:PrintTable(self.curItem)
        self.value_txt:setString("吞噬后可获得知识储备："..feisheng_deco_config[self.curItem.entry_id].count*self.curItem.num)
    end
end

--是否可吞噬
function DujiePanel:isCanDevour(item)
    local itemdata = GGetItemDataById(item.entry_id)
    if not itemdata then 
        return false 
    end
    if feisheng_deco_config[item.entry_id] then
        return true
    end
end

function DujiePanel:cellTouchEvent(event)
    if event.name == "ended" and event.item then
        if self.curSelect then
            self.curSelect:setImgSelect(false)
            self.curSelect = nil
        end
        if event.target.isSelect == true then
            event.target:setImgSelect(false)
        elseif event.target.isSelect == false then
            event.target:setImgSelect(true)
            self.curSelect = event.target
        end
        local function callFun(data)
            if data.index == 1 then
                self:SendNetInfo(event.item)
            elseif data.index == 2 then 
                GameUIManager:show_window(GameConfig.UI_EquimentAppraisal_PANEL)
            else
                GameUIManager:show_window(GameConfig.UI_EquipmentQuenching_PANEL)
            end
        end

        if GCheckIsEquip(GGetItemDataById(event.item.entry_id)) then
            local btnList = {[1]={name = "卸 下",index = 1},[2]={name = "鉴 定",index = 2},[3]={name = "淬 炼",index = 3},}   --1
            DetailManager:getInstance():setBtnCallBack(btnList,callFun)
        end
    end
end

function DujiePanel:Refresh()
    self:EquipmentsData(game_app.itemManager.equipList)  --装备数据
    self:DrawMyEquipment()
end

function DujiePanel:SendNetInfo(item)
    local protocal = ProtocalPool.GetCSPrototype(ProtocalCode.PT_Unload_Equipment)
    protocal.equipment_id = item.guid
    ProtocalPool.SendCMD(NET_ID, protocal)
end

function DujiePanel:SelectView(index)
    -- self.totalExp = 0
    if index == 1 then
        self.role_other_btn:loadTextureNormal("ntab_pub_2_n.png",1)
        self.role_base_btn:loadTextureNormal("ntab_pub_2_p.png",1)
        self.role_other_btn:setTitleColor(cc.c3b(150,138,98))
        self.role_base_btn:setTitleColor(cc.c3b(235,222,186))
        self.info_layer:setVisible(true)
        self.infobag_layer:setVisible(false)
    elseif index == 2 then
        self.role_other_btn:loadTextureNormal("ntab_pub_2_p.png",1)
        self.role_base_btn:loadTextureNormal("ntab_pub_2_n.png",1)
        self.role_base_btn:setTitleColor(cc.c3b(150,138,98))
        self.role_other_btn:setTitleColor(cc.c3b(235,222,186))
        self.info_layer:setVisible(false)
        self.infobag_layer:setVisible(true)
    end
end

function DujiePanel:CreateItemsPage(num)
    local spacing_v, spacing_h, slotMatrix = nil, nil, nil
    self.ypos=0
    if num == 1 then
        spacing_v, spacing_h = 15, 423
        slotMatrix = EquipPageTitles
        self.ypos=48
    elseif num == 2 then
        spacing_v, spacing_h = 15, 423
        slotMatrix = EquipPageTitles
        self.ypos=48
    elseif num == 3 then
        spacing_v, spacing_h = 15, 423
        slotMatrix = EquipPageTitles
        self.ypos=48
    elseif num == 4 then
        spacing_v, spacing_h = 15, 423
        slotMatrix = EquipPageTitles
        self.ypos=48
    else            
        return
    end
    if self.cellPages[num] then
        return
    end
    local rows, cols = table.maxn(slotMatrix), table.maxn(slotMatrix[1])
    self.cellPages[num]=ItemsPage:create(nil,0,0,rows,cols,spacing_h,spacing_v,handler(self,self["cellTouchEvent"]),false,nil,nil,slotMatrix ,false , true , true )
    self.cellPages[num]:setPosition(-453,-180)
    self.game_layer:addChild(self.cellPages[num])
    if num~=1 then
        self.cellPages[num]:setVisible(false)
        --self.cellPages[num]:setPosition(-453+10,-270+50)
    end
end

--获取身上装备数据
function DujiePanel:EquipmentsData(equipmentData)
    local tab = equipmentData
    self.CurEquipment = {}
    for k,v in pairs(tab) do
        self.CurEquipment[v.index] = {}
        self.CurEquipment[v.index] = v 
    end
    self:updateRoleModelEx()
end

--绘画自己的装备
function DujiePanel:DrawMyEquipment()
    local Idx = nil
    local bagItem = nil
    local MaxItem = nil
    for i=2301,2354 do
        if(self.CurEquipment[i])  then 
           
            local v = self.CurEquipment[i]
            self:DrawEquipmentCell(v,bagItem,i,MaxItem)
        else
            local slot = SlotPage1[i+1] or SlotPage2[i+1] or SlotPage3[i+1] or SlotPage4[i+1] 
            if slot then                    
                local page = self.cellPages[slot.p]
                local cell = page and page:getItemCellAt(slot.r, slot.c) or nil
                if cell then
                    cell:resetCell()
                    if cell.addBtn then
                        cell.addBtn:removeFromParent()
                        cell.addBtn = nil
                    end
                    local show,list,tablelist=self:findBagEquip(i)
                    if show then
                        local  index = self:betterEquip(tablelist)
                        local img=ccui.ImageView:create("nimg_qhjia_1.png",1)
                        local btn=UIBuilder.CreateButton(nil,{normal="nimg_qhjia_1.png"})
                        cell.addBtn = btn
                        cell:addChild(btn,99,nil, cell.posx , cell.posy )
                        btn:addClickEventListener(function ( ... )
                            game_app.itemManager:useItem(list[index])   
                        end)
                    end
                end
            end 
        end 
    end 
end

--背包中寻找自己的物品
function DujiePanel:findBagEquip(index)
    local id=EquipIndexArea[index+1]
    local bagList=game_app.itemManager.bagList
    local isshow=false
    local list={}
    local tablelist={}
    for k,v in pairs(bagList) do
        -- cclog(v.entry_id)
        if GameConfig.CnfItem[v.entry_id] and GameConfig.CnfItem[v.entry_id].inventorytype==id then--槽位一样
            isshow=true
            table.insert(list,v)
            table.insert(tablelist,GameConfig.CnfItem[v.entry_id])
        end
    end
    return isshow,list,tablelist
end

function DujiePanel:betterEquip( info )
    local curItemData = nil
    local index = 0
    local level = GGetPlayerAttr("level") --人物等级 
    local zs_level = GGetPlayerAttr("zs_level") or 0 --转生等级
    local job= GGetPlayerAttr("job") --职业
    for k,v in pairs( info ) do
        if v.EquipFlyLevel <= zs_level and (job==v.allowableclass or v.allowableclass==0) and v.requiredlevel <= level  then
            if curItemData then
                if ( curItemData.zhanli or 0 ) < ( v.zhanli or 0 ) then
                    index = k
                    curItemData = v 
                end
            else
               index = k
               curItemData = v
            end
        end
    end
    return index
end

---绘画装备格子
function DujiePanel:DrawEquipmentCell(curdata,suitData,Idx,maxItem)
    local  bagData = nil
    local slot = SlotPage1[Idx+1] or SlotPage2[Idx+1] or SlotPage3[Idx+1] or SlotPage4[Idx+1]
    if(suitData)then 
        bagData    = GGetItemDataById(suitData.entry_id) --背包装备的本地数据
    end 
    if slot then 
        local page = self.cellPages[slot.p]
        local cell = page and page:getItemCellAt(slot.r, slot.c) or nil
        if cell then
           -- cell.btn_item:loadTextures("nitem_bg.png","nitem_bg.png","nitem_bg.png",1)
            if cell.addBtn then
               cell.addBtn:removeFromParent()
               cell.addBtn = nil
            end
            cell:updateByItem(curdata)
            local item_data =  GGetItemDataById(curdata.entry_id)
            if(bagData)then 
                local cur_guid_level = item_data.zhanli or 0
                local bag_guid_level = bagData.zhanli or 0
                if(cur_guid_level<bag_guid_level) and item_data.inventorytype==bagData.inventorytype  then 
                else
                    if(maxItem)then --(PS:maxItem表示不合适条件穿戴的，但是又有比较好的)
                    end
                end 
            elseif(maxItem)then
            end
        end
    end
end

function DujiePanel:onTouchCallBack( sender, eventType )
    if sender then
        if eventType == ccui.TouchEventType.ended then
            local name  = sender:getName()
            if name == "select_btn_1" then
                self:showEquipPageByIndex( 1 )
            elseif name == "select_btn_2" then
                self:showEquipPageByIndex( 2 )
            elseif name == "select_btn_3" then
                self:showEquipPageByIndex( 3 )
            else
                self:showEquipPageByIndex( 4 )
            end
        end
    end
end

function DujiePanel:showEquipPageByIndex( pageIndex )
    for k,cellPage in ipairs( self.cellPages ) do
        if k ~= pageIndex then
            cellPage:setVisible(false)
        else
            cellPage:setVisible(true)
        end
    end
    self.figure:loadTexture(figureList[pageIndex],1)
    self.imgSelect:setPosition( self.btnPoses[ pageIndex ] )
end

function DujiePanel:show(root)
    self.super.show(self,root)
end

function DujiePanel:showFinishCall( )
  
end

function DujiePanel:ListenNetWorkMsg(msg_type, msg_data)
    if msg_type==ProtocalCode.PT_Unload_Equipment then
       self:Refresh()  --装备数据  
    end
end

function DujiePanel:destroy()
    if self.OtherBuyPanel then
        self.OtherBuyPanel:destroy()
        self.OtherBuyPanel = nil
    end
    game_app:CancelGameNotify( GameConfig.NOTIFY_ITEM_CHANGE ,  self.refreshHandler )
    game_app:CancelGameNotify( GameConfig.NOTIFY_ROLE_INFO,self.updateNet )
    game_app:CancelGameNotify( GameConfig.NOTIFY_ITEM_CHANGE , self.updateChangeItem )
    NetWorkHandleMsg.RemoveMsgHandle(ProtocalCode.PT_Unload_Equipment)
    -- self.roleEff:destroy()
    self.effect:destroy()

    package.loaded["scripts/UI/Dlg/role/DujiePanel"] = nil
    self.super.destroy(self)
end
return DujiePanel