function SimulationUtility.findEscorterInFaction(faction, escorter)
    local shipNames = {faction:getShipNames()}
    for _, name in pairs(shipNames) do
        if name == escorter then
            return true
        end
    end
end

--unfortunately have to hard-replace this function since our new functionality needs to go in the middle
function SimulationUtility.isShipUsableAsEscort(escorter, escortee)
    if escorter == escortee then
        return SimulationUtility.EscortError.Unavailable
    end

    local faction = getParentFaction()
    
    if not SimulationUtility.findEscorterInFaction(faction, escorter) then
        if faction.alliance or Faction(faction.allianceIndex) then
            faction = Alliance(faction) or Faction(faction.allianceIndex)
            if not SimulationUtility.findEscorterInFaction(faction, escorter) then
                return SimulationUtility.EscortError.Unavailable
            end
        end
    end

    local sx, sy = faction:getShipPosition(escortee)

    if faction:getShipAvailability(escorter) ~= ShipAvailability.Available then
        return SimulationUtility.EscortError.Unavailable
    end

    local databaseEntry = ShipDatabaseEntry(faction.index, escorter)
    local reach, canPassRifts, cooldown = databaseEntry:getHyperspaceProperties()

    local ex, ey = databaseEntry:getCoordinates()

    if distance2(vec2(ex, ey), vec2(sx, sy)) > reach * reach then
        return SimulationUtility.EscortError.TooFarAway
    end

    if not canPassRifts then
        if Balancing_InsideRing(ex, ey) ~= Balancing_InsideRing(sx, sy) then
            return SimulationUtility.EscortError.Unreachable
        end
    end

    local usableError = SimulationUtility.isShipUsable(faction.index, escorter)
    if usableError then
        return SimulationUtility.EscortError.Unusable, usableError
    end

end
