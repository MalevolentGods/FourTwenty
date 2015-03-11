
-- file refrences
local Assets =
{

   Asset("ANIM", "anim/joint.zip"),
   Asset("ANIM", "anim/swap_joint.zip"),
   Asset("ANIM", "anim/blow_dart.zip"),
   Asset("ANIM", "anim/swap_joint_pipe.zip"),

   Asset("ATLAS", "images/inventoryimages/joint.xml"),
   Asset("IMAGE", "images/inventoryimages/joint.tex"),
}

-- change animation state for item
-- UVs based off of swap_ham_bat
local function OnEquip(inst, owner)

    --owner.AnimState:OverrideSymbol("swap_object", "swap_joint", "swap_joint")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

-- change animation state for empty hands
local function OnUnequip(inst, owner)
   owner.AnimState:ClearOverrideSymbol("swap_object")
   owner.AnimState:Hide("ARM_carry")
   owner.AnimState:Show("ARM_normal")

end


local function onfinished(inst)
    inst:Remove()
end



-- local function that creats, customizes, and returns an instance of the prefab.
-- pipe dropped UVs based off of horn
local function fn(Sim)

    local inst = CreateEntity()
      inst.entity:AddTransform()
      inst.entity:AddAnimState()
      inst.entity:AddNetwork()
      MakeInventoryPhysics(inst)

      inst.AnimState:SetBank("blow_dart")
      inst.AnimState:SetBuild("blow_dart")
      inst.AnimState:PlayAnimation("idle")

      if not TheWorld.ismastersim then
        return inst
      end

      inst.entity:SetPristine()
	  
      inst:AddComponent("inspectable")
	  
      inst:AddComponent("inventoryitem")
      inst.components.inventoryitem.imagename = "joint"
      inst.components.inventoryitem.atlasname = "images/inventoryimages/joint.xml"

      inst:AddComponent("equippable")
      inst.components.equippable:SetOnEquip(OnEquip)
      inst.components.equippable:SetOnUnequip(OnUnequip)
	  
      inst:AddTag("horn")
	  
      inst:AddComponent("instrument")
      inst.AnimState:SetBank("smoke")
      inst.AnimState:SetBuild("horn")
      inst.AnimState:PlayAnimation("idle")
	  
      --MakeInventoryPhysics(inst)
      inst:AddComponent("tokeable")
      --inst:AddComponent("tool")
      --inst.components.tool:SetAction(ACTIONS.TOKE)
      

      inst:AddComponent("finiteuses")
      inst.components.finiteuses:SetMaxUses(TUNING.HORN_USES)
      inst.components.finiteuses:SetUses(TUNING.HORN_USES)
      inst.components.finiteuses:SetOnFinished(onfinished)
      inst.components.finiteuses:SetConsumption(ACTIONS.TOKE, 1)


    return inst

end


STRINGS.NAMES.PIPE = "Rolled Joint"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIPE = "It's like a work of art that you can smoke."

-- return prefab
return Prefab("common/inventory/joint", fn, Assets)

