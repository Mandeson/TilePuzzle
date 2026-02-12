Direction = {UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3}

Directions = {
    [Direction.UP] = {x = 0, y = -1},
    [Direction.DOWN] = {x = 0, y = 1},
    [Direction.LEFT] = {x = -1, y = 0},
    [Direction.RIGHT] = {x = 1, y = 0}
}

function Engine.init()
    Texture = Engine.Texture.load("puzzle.png")

    local margin = 5
    local tileSize = 480
    GridSize = 4
    Tiles = {}
    Board = {}

    -- First row
    Board[1] = {}
    for x=1,GridSize - 1 do
        AddTile(x, 1, margin, tileSize)
    end
    Board[1][GridSize] = {tileId = 0} -- Empty tile

    -- Other rows
    for y=2,GridSize do
        Board[y] = {}
        for x=1,GridSize do
            AddTile(x, y, margin, tileSize)
        end
    end

    UpdateTiles()
end

function AddTile(x, y, margin, tileSize)
    Tiles[#Tiles + 1] = Engine.Sprite.new(Texture,
            margin + (x - 1) * (tileSize + margin),
            margin + (y - 1) * (tileSize + margin), tileSize, tileSize)
    Board[y][x] = {tileId = #Tiles}
end

function UpdateTiles()
    local windowSizeX, windowSizeY = Engine.Window.getSize()
    local minSize = math.min(windowSizeX, windowSizeY)
    TileSize = math.floor(minSize / GridSize * 0.95)
    local margin = math.floor(minSize * 0.005)
    local boardSize = TileSize * GridSize + margin * (GridSize - 1)
    local startX = math.floor(windowSizeX / 2 - boardSize / 2)
    local startY = math.floor(windowSizeY / 2 - boardSize / 2)

    for y=1,GridSize do
        for x=1,GridSize do
            local tile = Board[y][x]
            local tileSprite = Tiles[tile.tileId]
            if tileSprite then
                tileSprite:setSize(TileSize, TileSize)

                local space = (TileSize + margin)

                local tilePosX = startX + (x - 1) * space
                local tilePosY = startY + (y - 1) * space

                if tile.move then
                    local moveDirection = Directions[tile.move]
                    local animation = AnimationCurve(tile.movePhase)
                    tilePosX = tilePosX + animation * moveDirection.x * space
                    tilePosY = tilePosY + animation * moveDirection.y * space
                end

                tileSprite:setPos(tilePosX, tilePosY)
            end
        end
    end
end

function AnimationCurve(phase)
    if phase <= 0.5 then
        return 2 * phase * phase
    else
        phase = phase - 0.5
        return 2 * phase * (1 - phase) + 0.5
    end
end

function GetTileFromCoords(x, y)
    for gridX=1,GridSize do
        for gridY=1,GridSize do
            local tile = Board[gridY][gridX]
            local tileSprite = Tiles[tile.tileId]
            if tileSprite then
                local tileX, tileY = tileSprite:getPos()
                if x >= tileX and x <= tileX + TileSize
                        and y >= tileY and y <= tileY + TileSize
                then
                    return {x= gridX, y = gridY}
                end
            end
        end
    end
    return nil
end

function PressTile(gridX, gridY)
    local tile = Board[gridY][gridX]
    local nearbyTiles = {
        {x = gridX, y = gridY - 1, direction = Direction.UP},
        {x = gridX, y = gridY + 1, direction = Direction.DOWN},
        {x = gridX - 1, y = gridY, direction = Direction.LEFT},
        {x = gridX + 1, y = gridY, direction = Direction.RIGHT}
    }

    for _,nearbyTile in ipairs(nearbyTiles) do
        local row = Board[nearbyTile.y]
        if row then
            local checkedTile = row[nearbyTile.x]
            if checkedTile and checkedTile.tileId == 0 then
                tile.move = nearbyTile.direction
                tile.movePhase = 0.0
                Moving = true
                return
            end
        end
    end
end

function Engine.timeStep(time)
    for y=1,GridSize do
        for x=1,GridSize do
            local tile = Board[y][x]
            if tile.tileId ~= 0 and tile.move then
                tile.movePhase = tile.movePhase + time * 4.0
                if tile.movePhase >= 1.0 then
                    local moveDirection = Directions[tile.move]
                    local destination = Board[y + moveDirection.y][x + moveDirection.x]

                    Moving = false
                    tile.move = nil
                    tile.movePhase = nil

                    destination.tileId, tile.tileId = tile.tileId, 0
                end
            end
        end
    end
    UpdateTiles()
end

function Engine.Mouse.buttonPressed(button, x, y)
    if Moving then return end
    local foundTile = GetTileFromCoords(x, y)
    if foundTile then
        PressTile(foundTile.x, foundTile.y)
    end
end

Pointers = {}

function Engine.Touchscreen.pointerDown(x, y, id)
    local foundTile = GetTileFromCoords(x, y)
    if foundTile then
        Pointers[id] = Board[foundTile.y][foundTile.x];
    end
end

function Engine.Touchscreen.pointerUp(x, y, id)
    local tile = Pointers[id]
    if tile then
        local foundTile = GetTileFromCoords(x, y)
        if foundTile and not Moving and tile == Board[foundTile.y][foundTile.x] then
            PressTile(foundTile.x, foundTile.y)
        end
        Pointers[id] = nil
    end
end

function Engine.Touchscreen.pointerMove(x, y, id)

end

function Engine.Touchscreen.pointerCancel()

end
