--- joint.lua ---
------------------------------------------------------
-- Type: Prefab
-- Description: Creates and defines the joint
------------------------------------------------------

-- Custom animation and inventory image
local assets =
{
  	Asset("ANIM", "anim/joint.zip"),
   	Asset("ANIM", "anim/swap_joint.zip"),
   	Asset("ATLAS", "images/inventoryimages/joint.xml"),
   	Asset("IMAGE", "images/inventoryimages/joint.tex"),
}

-- Remove from inventory when depleted
local function onfinished(inst)
    inst:Remove()
end

-- Define the joint
local function fn(Sim)

    -- Boilerplate
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    -- Give it inventory physics?	
	MakeInventoryPhysics(inst)

    -- Define the animation
	inst.AnimState:SetBank("joint")
    inst.AnimState:SetBuild("joint")
    inst.AnimState:PlayAnimation("idle")

    -- Still groking this one. Needed for multiplayer.
	if not TheWorld.ismastersim then
		return inst
    end

    -- This one too
    inst.entity:SetPristine()

    -- Make it inspectable
    inst:AddComponent("inspectable")
	
    -- Make it something that can go in your inventory
	inst:AddComponent("inventoryitem")

    -- Set the inventory name and image
    inst.components.inventoryitem.imagename = "joint"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/joint.xml"
	
    -- Give it our custom joint tag
    inst:AddTag("joint")

    -- Give it the instrument tag (custom animation relies on this)
    inst:AddComponent("instrument")

    -- Give it our custom tokeable tag (makes it something that can be smoked)
    inst:AddComponent("tokeable")

    -- Define the sanity boost 
    -- TODO: make this configurable and/or better balanced
	inst.components.tokeable:SetSanityBoost(TUNING.SANITY_MED)

    -- Make it depletable
    inst:AddComponent("finiteuses")

    -- Configure how many uses
    -- TODO: revisit for balance
    inst.components.finiteuses:SetMaxUses(TUNING.HORN_USES)
    inst.components.finiteuses:SetUses(TUNING.HORN_USES)

    -- What to do when depleted (remove)
    inst.components.finiteuses:SetOnFinished(onfinished)

    -- Define tokes
    inst.components.finiteuses:SetConsumption(ACTIONS.TOKE, 1)
	
    return inst
end

-- Return a joint
return Prefab("common/inventory/joint", fn, assets)

