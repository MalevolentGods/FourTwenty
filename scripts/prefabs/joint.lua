--This script creates and defines the joint prefab
------------------------------------------------------

local assets =
{
  	Asset("ANIM", "anim/joint.zip"),
   	Asset("ANIM", "anim/swap_joint.zip"),
   	Asset("ATLAS", "images/inventoryimages/joint.xml"),
   	Asset("IMAGE", "images/inventoryimages/joint.tex"),
}

local function onfinished(inst)
    inst:Remove()
end

local function fn(Sim)

    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    	
	MakeInventoryPhysics(inst)
    
	inst.AnimState:SetBank("joint")
    inst.AnimState:SetBuild("joint")
    inst.AnimState:PlayAnimation("idle")

	if not TheWorld.ismastersim then
		return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "joint"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/joint.xml"
	
    inst:AddTag("joint")


    inst:AddComponent("instrument")

    inst:AddComponent("tokeable")
	inst.components.tokeable:SetSanityBoost(TUNING.SANITY_MED)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.HORN_USES)
    inst.components.finiteuses:SetUses(TUNING.HORN_USES)
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.TOKE, 1)
	
    return inst
end

return Prefab("common/inventory/joint", fn, assets)

