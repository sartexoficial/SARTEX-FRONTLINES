--==============================================================

-- SARTEX FRONTLINES V2.4 UNDERGROUND GHOST

--

-- P   = abrir/fechar painel

-- RMB = segurar AIM

--

-- MAIS PUXANTE QUE V1.9

-- • Hard Lock por RMB

-- • Não troca de inimigo

-- • Aim via mousemoverel

-- • Força alta longe/médio

-- • Freio próximo do alvo

-- • Anti overshoot

-- • Anti tremedeira

--==============================================================

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local PlayerGui = LP:WaitForChild("PlayerGui")

local Camera = workspace.CurrentCamera

local ENV = _G

pcall(function()

    if getgenv then

        ENV = getgenv()

    end

end)

--==============================================================

-- CLEAN OLD

--==============================================================

if ENV.SARTEX_FRONTLINES_CLEANUP then

    pcall(ENV.SARTEX_FRONTLINES_CLEANUP)

end

pcall(function()

    RunService:UnbindFromRenderStep(

        "SARTEX_FRONTLINES_AIM"

    )

end)

pcall(function()

    RunService:UnbindFromRenderStep(

        "SARTEX_FRONTLINES_GHOST"

    )

end)

for _,name in ipairs({

    "SARTEX_FRONTLINES_V15",

    "SARTEX_FRONTLINES_V16",

    "SARTEX_FRONTLINES_V17",

    "SARTEX_FRONTLINES_V18",

    "SARTEX_FRONTLINES_V19",

    "SARTEX_FRONTLINES_V20",

    "SARTEX_FRONTLINES_V21",

    "SARTEX_FRONTLINES_V22",

    "SARTEX_FRONTLINES_V23",

    "SARTEX_FRONTLINES_V24"

}) do

    local old = PlayerGui:FindFirstChild(name)

    if old then

        old:Destroy()

    end

end

--==============================================================

-- CONFIG

--==============================================================

local Config = {

    --==========================================================

    -- AIM

    --==========================================================

    Aim = true,

    FOV = 450,

    ShowFOV = true,

    HardTargetLock = true,

    WallCheck = true,

    TeamCheck = false,

    --==========================================================

    -- FORÇA GERAL

    --

    -- V1.9 = 1.00

    -- V2.2 = 1.00

    --==========================================================

    AimStrength = 1.00,

    AimStrengthStep = 0.10,

    AimStrengthMin = 0.30,

    AimStrengthMax = 3.00,

    --==========================================================

    -- STABLE LOCK

    --==========================================================

    AimDeadzone = 2.0,

    AimReacquire = 4.0,

    AimTargetFilter = 34.0,

    AimFarResponse = 24.0,

    AimMidResponse = 20.0,

    AimNearResponse = 13.0,

    AimMicroResponse = 7.0,

    AimFarRadius = 190,

    AimMidRadius = 80,

    AimNearRadius = 26,

    AimFarMaxStep = 20.0,

    AimMidMaxStep = 15.0,

    AimNearMaxStep = 8.0,

    AimMicroMaxStep = 3.0,

    AimAcceleration = 6.0,

    AimHardMaxStep = 28.0,

    AimNearErrorFactor = 0.48,

    AimMidErrorFactor = 0.66,

    AimFarErrorFactor = 0.80,

    --==========================================================

    -- CHEST AIM

    --==========================================================

    AimChestFallbackHeight = 1.65,

    --==========================================================

    -- UNDERGROUND GHOST

    --==========================================================

    UndergroundGhost = false,

    UndergroundDepth = 8.0,

    GhostCameraOffset = true,

    GhostVisualClone = true,

    --==========================================================

    -- ESP

    --==========================================================

    ESP = true,

    ESPStyle = "FULL",

    ESPFPS = 120,

    ShowDistance = true,

    VisibleColor = true

}

--==============================================================

-- COLORS

--==============================================================

local Colors = {

    Gold = Color3.fromRGB(

        225,

        180,

        55

    ),

    Red = Color3.fromRGB(

        255,

        65,

        70

    ),

    Green = Color3.fromRGB(

        65,

        230,

        125

    ),

    White = Color3.fromRGB(

        240,

        240,

        245

    ),

    Muted = Color3.fromRGB(

        125,

        128,

        140

    ),

    BG = Color3.fromRGB(

        8,

        8,

        11

    ),

    Card = Color3.fromRGB(

        17,

        17,

        22

    )

}

--==============================================================

-- STATE

--==============================================================

local Destroyed = false

local RMB = false

local CurrentTarget = nil

local SelectedThisHold = false

local AimSettled = false

local SmoothedDelta = nil

local AimVelocity = Vector2.zero

local LastRawDelta = nil

local Rigs = {}

local Visuals = {}

local Connections = {}

local GhostClone = nil

local GhostCloneMap = {}

local GhostOriginalTransparency = {}

local GhostOriginalCollide = {}

local GhostCharacter = nil

local GhostRoot = nil

local GhostApplied = false

local AimInputMode = "PROCURANDO..."

--==============================================================

-- CONNECTION

--==============================================================

local function Connect(signal,callback)

    local c = signal:Connect(callback)

    table.insert(

        Connections,

        c

    )

    return c

end

--==============================================================

-- GUI

--==============================================================

local GUI = Instance.new("ScreenGui")

GUI.Name = "SARTEX_FRONTLINES_V23"

GUI.IgnoreGuiInset = true

GUI.ResetOnSpawn = false

GUI.DisplayOrder = 999999

GUI.Parent = PlayerGui

--==============================================================

-- FOV

--==============================================================

local FOVCircle = Instance.new("Frame")

FOVCircle.AnchorPoint =

    Vector2.new(

        0.5,

        0.5

    )

FOVCircle.BackgroundTransparency = 1

FOVCircle.BorderSizePixel = 0

FOVCircle.Parent = GUI

local FOVCorner = Instance.new("UICorner")

FOVCorner.CornerRadius =

    UDim.new(

        1,

        0

    )

FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")

FOVStroke.Color = Colors.Gold

FOVStroke.Thickness = 1.2

FOVStroke.Transparency = 0.25

FOVStroke.Parent = FOVCircle

--==============================================================

-- PANEL

--==============================================================

local Panel = Instance.new("Frame")

Panel.Size =

    UDim2.fromOffset(

        430,

        465

    )

Panel.Position =

    UDim2.fromOffset(

        25,

        90

    )

Panel.BackgroundColor3 = Colors.BG

Panel.BorderSizePixel = 0

Panel.Parent = GUI

local PC = Instance.new("UICorner")

PC.CornerRadius =

    UDim.new(

        0,

        12

    )

PC.Parent = Panel

local PS = Instance.new("UIStroke")

PS.Color = Colors.Gold

PS.Thickness = 1.5

PS.Parent = Panel

--==============================================================

-- TITLE

--==============================================================

local Title = Instance.new("TextLabel")

Title.Position =

    UDim2.fromOffset(

        17,

        10

    )

Title.Size =

    UDim2.new(

        1,

        -34,

        0,

        30

    )

Title.BackgroundTransparency = 1

Title.Text = "SARTEX • FRONTLINES V2.4"

Title.TextColor3 = Colors.Gold

Title.Font = Enum.Font.GothamBold

Title.TextSize = 17

Title.TextXAlignment =

    Enum.TextXAlignment.Left

Title.Parent = Panel

local Subtitle = Instance.new("TextLabel")

Subtitle.Position =

    UDim2.fromOffset(

        17,

        37

    )

Subtitle.Size =

    UDim2.new(

        1,

        -34,

        0,

        16

    )

Subtitle.BackgroundTransparency = 1

Subtitle.Text =

    "RMB AIM • P PANEL • UNDERGROUND GHOST"

Subtitle.TextColor3 = Colors.Muted

Subtitle.Font = Enum.Font.Gotham

Subtitle.TextSize = 9

Subtitle.TextXAlignment =

    Enum.TextXAlignment.Left

Subtitle.Parent = Panel

--==============================================================

-- STATUS

--==============================================================

local Status = Instance.new("TextLabel")

Status.Position =

    UDim2.fromOffset(

        17,

        65

    )

Status.Size =

    UDim2.new(

        1,

        -34,

        0,

        82

    )

Status.BackgroundColor3 = Colors.Card

Status.TextColor3 = Colors.White

Status.Font = Enum.Font.Code

Status.TextSize = 11

Status.TextXAlignment =

    Enum.TextXAlignment.Left

Status.TextYAlignment =

    Enum.TextYAlignment.Top

Status.TextWrapped = true

Status.Parent = Panel

local StatusCorner =

    Instance.new("UICorner")

StatusCorner.CornerRadius =

    UDim.new(

        0,

        8

    )

StatusCorner.Parent = Status

--==============================================================

-- CONTROLS

--==============================================================

local Controls =

    Instance.new("ScrollingFrame")

Controls.Position =

    UDim2.fromOffset(

        17,

        160

    )

Controls.Size =

    UDim2.new(

        1,

        -34,

        1,

        -177

    )

Controls.BackgroundTransparency = 1

Controls.BorderSizePixel = 0

Controls.ScrollBarThickness = 2

Controls.ScrollBarImageColor3 = Colors.Gold

Controls.AutomaticCanvasSize =

    Enum.AutomaticSize.Y

Controls.CanvasSize = UDim2.new()

Controls.Parent = Panel

local ControlsLayout =

    Instance.new("UIListLayout")

ControlsLayout.Padding =

    UDim.new(

        0,

        7

    )

ControlsLayout.Parent = Controls

--==============================================================

-- BUTTON

--==============================================================

local function NewButton(text,callback)

    local b =

        Instance.new("TextButton")

    b.Size =

        UDim2.new(

            1,

            -4,

            0,

            35

        )

    b.BackgroundColor3 = Colors.Card

    b.BorderSizePixel = 0

    b.Text = text

    b.TextColor3 = Colors.White

    b.Font = Enum.Font.GothamBold

    b.TextSize = 10

    b.AutoButtonColor = false

    b.Parent = Controls

    local c =

        Instance.new("UICorner")

    c.CornerRadius =

        UDim.new(

            0,

            7

        )

    c.Parent = b

    Connect(

        b.MouseButton1Click,

        function()

            callback(b)

        end

    )

    return b

end

--==============================================================

-- UNDERGROUND GHOST

--==============================================================

local function GhostDestroyClone()

    if GhostClone then

        pcall(function()

            GhostClone:Destroy()

        end)

    end

    GhostClone = nil

    GhostCloneMap = {}

end

local function GhostRestoreCharacter()

    if GhostCharacter and GhostCharacter.Parent then

        for obj,value in pairs(GhostOriginalTransparency) do

            if obj and obj.Parent then

                pcall(function()

                    obj.LocalTransparencyModifier = value

                end)

            end

        end

        for obj,value in pairs(GhostOriginalCollide) do

            if obj and obj.Parent then

                pcall(function()

                    obj.CanCollide = value

                end)

            end

        end

    end

    GhostOriginalTransparency = {}

    GhostOriginalCollide = {}

end

local function GhostPath(obj,root)

    local names = {}

    local cur = obj

    while cur and cur ~= root do

        table.insert(names,1,cur.Name)

        cur = cur.Parent

    end

    return table.concat(names,"/")

end

local function GhostBuildClone(character)

    GhostDestroyClone()

    if

        not Config.GhostVisualClone

        or

        not character

        or

        not character.Parent

    then

        return

    end

    local oldArchivable = character.Archivable

    character.Archivable = true

    local ok,clone = pcall(function()

        return character:Clone()

    end)

    character.Archivable = oldArchivable

    if

        not ok

        or

        not clone

    then

        return

    end

    clone.Name = "SARTEX_LOCAL_GHOST"

    for _,obj in ipairs(clone:GetDescendants()) do

        if

            obj:IsA("Script")

            or

            obj:IsA("LocalScript")

        then

            obj:Destroy()

        elseif obj:IsA("BasePart") then

            obj.Anchored = true

            obj.CanCollide = false

            pcall(function()

                obj.CanTouch = false

            end)

            pcall(function()

                obj.CanQuery = false

            end)

        end

    end

    clone.Parent = workspace

    GhostClone = clone

    local originalsByPath = {}

    for _,obj in ipairs(character:GetDescendants()) do

        if obj:IsA("BasePart") then

            originalsByPath[GhostPath(obj,character)] = obj

        end

    end

    GhostCloneMap = {}

    for _,obj in ipairs(clone:GetDescendants()) do

        if obj:IsA("BasePart") then

            local original =

                originalsByPath[

                    GhostPath(obj,clone)

                ]

            if original then

                GhostCloneMap[original] = obj

            end

        end

    end

end

local function GhostPrepareCharacter(character)

    GhostRestoreCharacter()

    GhostDestroyClone()

    GhostCharacter = character

    GhostRoot = nil

    GhostApplied = false

    if

        not character

        or

        not character.Parent

    then

        return false

    end

    GhostRoot =

        character:FindFirstChild("HumanoidRootPart")

        or

        character:FindFirstChild("Torso")

        or

        character:FindFirstChild("UpperTorso")

    if not GhostRoot then

        return false

    end

    for _,obj in ipairs(character:GetDescendants()) do

        if obj:IsA("BasePart") then

            GhostOriginalTransparency[obj] =

                obj.LocalTransparencyModifier

            GhostOriginalCollide[obj] =

                obj.CanCollide

        end

    end

    GhostBuildClone(character)

    return true

end

local function GhostMoveRealBodyDown()

    if

        not GhostRoot

        or

        not GhostRoot.Parent

        or

        GhostApplied

    then

        return

    end

    pcall(function()

        GhostRoot.CFrame =

            GhostRoot.CFrame

            -

            Vector3.new(

                0,

                Config.UndergroundDepth,

                0

            )

    end)

    GhostApplied = true

end

local function GhostMoveRealBodyUp()

    if

        not GhostRoot

        or

        not GhostRoot.Parent

        or

        not GhostApplied

    then

        return

    end

    pcall(function()

        GhostRoot.CFrame =

            GhostRoot.CFrame

            +

            Vector3.new(

                0,

                Config.UndergroundDepth,

                0

            )

    end)

    GhostApplied = false

end

local function GhostSetEnabled(enabled)

    Config.UndergroundGhost =

        enabled

        and

        true

        or

        false

    if not Config.UndergroundGhost then

        GhostMoveRealBodyUp()

        GhostRestoreCharacter()

        GhostDestroyClone()

        GhostCharacter = nil

        GhostRoot = nil

        return

    end

    if GhostPrepareCharacter(LP.Character) then

        GhostMoveRealBodyDown()

    end

end

local function GhostPhysicsStep()

    if

        not Config.UndergroundGhost

        or

        not GhostCharacter

        or

        not GhostCharacter.Parent

        or

        not GhostRoot

        or

        not GhostRoot.Parent

    then

        return

    end

    -- Local noclip lets the client-owned body keep moving
    -- below solid terrain instead of colliding with it.

    for _,obj in ipairs(GhostCharacter:GetDescendants()) do

        if obj:IsA("BasePart") then

            if GhostOriginalCollide[obj] == nil then

                GhostOriginalCollide[obj] = obj.CanCollide

            end

            obj.CanCollide = false

        end

    end

end

local function GhostRenderStep()

    if

        not Config.UndergroundGhost

        or

        not GhostCharacter

        or

        not GhostCharacter.Parent

        or

        not GhostRoot

        or

        not GhostRoot.Parent

    then

        return

    end

    for _,obj in ipairs(GhostCharacter:GetDescendants()) do

        if obj:IsA("BasePart") then

            if GhostOriginalTransparency[obj] == nil then

                GhostOriginalTransparency[obj] =

                    obj.LocalTransparencyModifier

            end

            obj.LocalTransparencyModifier = 1

        end

    end

    if

        Config.GhostVisualClone

        and

        GhostClone

        and

        GhostClone.Parent

    then

        local offset =

            Vector3.new(

                0,

                Config.UndergroundDepth,

                0

            )

        for original,clonePart in pairs(GhostCloneMap) do

            if

                original

                and

                original.Parent

                and

                clonePart

                and

                clonePart.Parent

            then

                clonePart.CFrame =

                    original.CFrame

                    +

                    offset

            end

        end

    end

    if

        Config.GhostCameraOffset

        and

        Camera

    then

        Camera.CFrame =

            Camera.CFrame

            +

            Vector3.new(

                0,

                Config.UndergroundDepth,

                0

            )

    end

end

Connect(

    LP.CharacterAdded,

    function(character)

        if not Config.UndergroundGhost then

            return

        end

        task.delay(

            0.35,

            function()

                if

                    Config.UndergroundGhost

                    and

                    character

                    and

                    character.Parent

                then

                    if GhostPrepareCharacter(character) then

                        GhostMoveRealBodyDown()

                    end

                end

            end

        )

    end

)

Connect(

    RunService.Stepped,

    function()

        GhostPhysicsStep()

    end

)

RunService:BindToRenderStep(

    "SARTEX_FRONTLINES_GHOST",

    Enum.RenderPriority.Camera.Value + 50,

    GhostRenderStep

)

--==============================================================

-- RESET

--==============================================================

local function ResetTarget()

    CurrentTarget = nil

    SelectedThisHold = false

    AimSettled = false

    SmoothedDelta = nil

    AimVelocity = Vector2.zero

    LastRawDelta = nil

end

--==============================================================

-- BUTTONS

--==============================================================

local AimButton =

    NewButton(

        "",

        function()

            Config.Aim =

                not Config.Aim

            ResetTarget()

        end

    )

local WallButton =

    NewButton(

        "",

        function()

            Config.WallCheck =

                not Config.WallCheck

            ResetTarget()

        end

    )

local TeamButton =

    NewButton(

        "",

        function()

            Config.TeamCheck =

                not Config.TeamCheck

            ResetTarget()

        end

    )

local ESPButton =

    NewButton(

        "",

        function()

            Config.ESP =

                not Config.ESP

        end

    )

local GhostButton =

    NewButton(

        "",

        function()

            GhostSetEnabled(

                not Config.UndergroundGhost

            )

        end

    )

local GhostDepthDownButton =

    NewButton(

        "",

        function()

            local wasEnabled =

                Config.UndergroundGhost

            if wasEnabled then

                GhostSetEnabled(false)

            end

            Config.UndergroundDepth =

                math.max(

                    3,

                    Config.UndergroundDepth - 1

                )

            if wasEnabled then

                GhostSetEnabled(true)

            end

        end

    )

local GhostDepthUpButton =

    NewButton(

        "",

        function()

            local wasEnabled =

                Config.UndergroundGhost

            if wasEnabled then

                GhostSetEnabled(false)

            end

            Config.UndergroundDepth =

                math.min(

                    20,

                    Config.UndergroundDepth + 1

                )

            if wasEnabled then

                GhostSetEnabled(true)

            end

        end

    )

local Styles = {

    "FULL",

    "SKELETON",

    "CORNER",

    "BOX",

    "HEAD",

    "HIGHLIGHT"

}

local StyleIndex = 1

local StyleButton =

    NewButton(

        "",

        function()

            StyleIndex =

                StyleIndex + 1

            if StyleIndex > #Styles then

                StyleIndex = 1

            end

            Config.ESPStyle =

                Styles[

                    StyleIndex

                ]

        end

    )

NewButton(

    "FOV -50",

    function()

        Config.FOV =

            math.max(

                50,

                Config.FOV - 50

            )

    end

)

NewButton(

    "FOV +50",

    function()

        Config.FOV =

            math.min(

                1000,

                Config.FOV + 50

            )

    end

)

local StrengthDownButton =

    NewButton(

        "",

        function()

            Config.AimStrength =

                math.max(

                    Config.AimStrengthMin,

                    Config.AimStrength - Config.AimStrengthStep

                )

            Config.AimStrength =

                math.floor(Config.AimStrength * 100 + 0.5) / 100

            ResetTarget()

        end

    )

local StrengthUpButton =

    NewButton(

        "",

        function()

            Config.AimStrength =

                math.min(

                    Config.AimStrengthMax,

                    Config.AimStrength + Config.AimStrengthStep

                )

            Config.AimStrength =

                math.floor(Config.AimStrength * 100 + 0.5) / 100

            ResetTarget()

        end

    )

--==============================================================

-- BONES

--==============================================================

local function FindBone(model,name)

    if not model then

        return nil

    end

    local o =

        model:FindFirstChild(

            name,

            true

        )

    if

        o

        and

        o:IsA("Bone")

    then

        return o

    end

    return nil

end

--==============================================================

-- BONE POSITION

--==============================================================

local function BonePosition(bone)

    if not bone then

        return nil

    end

    local ok,result =

        pcall(function()

            return

                bone.TransformedWorldCFrame.Position

        end)

    if

        ok

        and

        typeof(result)

        ==

        "Vector3"

    then

        return result

    end

    ok,result =

        pcall(function()

            return

                bone.WorldCFrame.Position

        end)

    if

        ok

        and

        typeof(result)

        ==

        "Vector3"

    then

        return result

    end

    ok,result =

        pcall(function()

            return

                bone.WorldPosition

        end)

    if

        ok

        and

        typeof(result)

        ==

        "Vector3"

    then

        return result

    end

    return nil

end

--==============================================================

-- BUILD RIG

--==============================================================

local function BuildRig(model)

    if

        not model

        or

        not model:IsA("Model")

        or

        model.Name ~= "soldier_model"

    then

        return nil

    end

    local hrp =

        model:FindFirstChild(

            "HumanoidRootPart",

            true

        )

    local head =

        FindBone(

            model,

            "Head_M"

        )

    local root =

        FindBone(

            model,

            "Root_M"

        )

    if

        not hrp

        or

        not head

        or

        not root

    then

        return nil

    end

    return {

        Model = model,

        HRP = hrp,

        Head = head,

        Root = root,

        Neck =

            FindBone(

                model,

                "Neck_M"

            ),

        Chest =

            FindBone(

                model,

                "Chest_M"

            ),

        Spine2 =

            FindBone(

                model,

                "Spine2_M"

            ),

        Spine1 =

            FindBone(

                model,

                "Spine1_M"

            ),

        ScapulaL =

            FindBone(

                model,

                "Scapula_L"

            ),

        ScapulaR =

            FindBone(

                model,

                "Scapula_R"

            ),

        ShoulderL =

            FindBone(

                model,

                "Shoulder_L"

            ),

        ShoulderR =

            FindBone(

                model,

                "Shoulder_R"

            ),

        ElbowL =

            FindBone(

                model,

                "Elbow_L"

            ),

        ElbowR =

            FindBone(

                model,

                "Elbow_R"

            ),

        WristL =

            FindBone(

                model,

                "Wrist_L"

            ),

        WristR =

            FindBone(

                model,

                "Wrist_R"

            ),

        HipL =

            FindBone(

                model,

                "Hip_L"

            ),

        HipR =

            FindBone(

                model,

                "Hip_R"

            ),

        KneeL =

            FindBone(

                model,

                "Knee_L"

            ),

        KneeR =

            FindBone(

                model,

                "Knee_R"

            ),

        AnkleL =

            FindBone(

                model,

                "Ankle_L"

            ),

        AnkleR =

            FindBone(

                model,

                "Ankle_R"

            ),

        StableAimHeight = nil

    }

end

--==============================================================

-- REMOVE VISUAL

--==============================================================

local function RemoveVisual(model)

    local v =

        Visuals[

            model

        ]

    if not v then

        return

    end

    for _,obj in pairs(v) do

        if typeof(obj) == "Instance" then

            pcall(function()

                obj:Destroy()

            end)

        elseif type(obj) == "table" then

            for _,child in pairs(obj) do

                pcall(function()

                    child:Destroy()

                end)

            end

        end

    end

    Visuals[model] = nil

end

--==============================================================

-- ADD RIG

--==============================================================

local function AddRig(model)

    if Rigs[model] then

        return

    end

    local rig =

        BuildRig(model)

    if rig then

        Rigs[model] = rig

    end

end

--==============================================================

-- REMOVE RIG

--==============================================================

local function RemoveRig(model)

    Rigs[model] = nil

    RemoveVisual(model)

    if

        CurrentTarget

        and

        CurrentTarget.Model == model

    then

        ResetTarget()

    end

end

--==============================================================

-- INITIAL SCAN

--==============================================================

for _,obj in ipairs(

    workspace:GetDescendants()

) do

    if

        obj:IsA("Model")

        and

        obj.Name == "soldier_model"

    then

        AddRig(obj)

    end

end

Connect(

    workspace.DescendantAdded,

    function(obj)

        if

            obj:IsA("Model")

            and

            obj.Name == "soldier_model"

        then

            task.delay(

                0.1,

                function()

                    if obj.Parent then

                        AddRig(obj)

                    end

                end

            )

        end

    end

)

Connect(

    workspace.DescendantRemoving,

    function(obj)

        if Rigs[obj] then

            RemoveRig(obj)

        end

    end

)

--==============================================================

-- TEAM

--==============================================================

local function Friendly(model)

    if not Config.TeamCheck then

        return false

    end

    return

        model:FindFirstChild(

            "friendly_marker",

            true

        )

        ~= nil

end

--==============================================================

-- CAMERA

--==============================================================

local function RefreshCamera()

    Camera =

        workspace.CurrentCamera

        or

        Camera

    return Camera

end

--==============================================================

-- CENTER

--==============================================================

local function Center()

    if not RefreshCamera() then

        return Vector2.zero

    end

    return

        Vector2.new(

            Camera.ViewportSize.X / 2,

            Camera.ViewportSize.Y / 2

        )

end

--==============================================================

-- WORLD TO SCREEN

--==============================================================

local function ToScreen(worldPos)

    if

        not worldPos

        or

        not RefreshCamera()

    then

        return nil

    end

    local p,visible =

        Camera:WorldToViewportPoint(

            worldPos

        )

    if

        not visible

        or

        p.Z <= 0

    then

        return nil

    end

    return

        Vector2.new(

            p.X,

            p.Y

        )

end

--==============================================================

-- AIM POINT

--==============================================================

local function AimPoint(rig)

    if

        not rig

        or

        not rig.HRP

        or

        not rig.HRP.Parent

    then

        return nil

    end

    local rootPos =

        rig.HRP.Position

    -- Aprende uma altura estável do peito uma única vez.
    -- Isso evita seguir o balanço do bone durante animações.

    if not rig.StableAimHeight then

        local chestPos =

            BonePosition(rig.Chest)

            or

            BonePosition(rig.Spine2)

            or

            BonePosition(rig.Spine1)

        if chestPos then

            rig.StableAimHeight =

                math.clamp(

                    chestPos.Y - rootPos.Y,

                    0.8,

                    3.4

                )

        else

            rig.StableAimHeight =

                Config.AimChestFallbackHeight

        end

    end

    return

        rootPos

        +

        Vector3.new(

            0,

            rig.StableAimHeight,

            0

        )

end

--==============================================================

-- VISIBILITY

--==============================================================

local function Visible(rig)

    if not Config.WallCheck then

        return true

    end

    if

        not rig

        or

        not Camera

    then

        return false

    end

    local targetPos =

        AimPoint(rig)

    if not targetPos then

        return false

    end

    local origin =

        Camera.CFrame.Position

    local ignore = {}

    if LP.Character then

        table.insert(

            ignore,

            LP.Character

        )

    end

    if Camera then

        table.insert(

            ignore,

            Camera

        )

    end

    for _ = 1,8 do

        local params =

            RaycastParams.new()

        params.FilterType =

            Enum.RaycastFilterType.Exclude

        params.FilterDescendantsInstances =

            ignore

        params.IgnoreWater =

            true

        local hit =

            workspace:Raycast(

                origin,

                targetPos - origin,

                params

            )

        if not hit then

            return true

        end

        if

            hit.Instance:IsDescendantOf(

                rig.Model

            )

        then

            return true

        end

        if

            hit.Instance:IsA("BasePart")

            and

            hit.Instance.Transparency >= 0.97

        then

            table.insert(

                ignore,

                hit.Instance

            )

        else

            return false

        end

    end

    return false

end

--==============================================================

-- CAN ACQUIRE

--==============================================================

local function CanAcquireTarget(rig)

    if

        not rig

        or

        not rig.Model

        or

        not rig.Model.Parent

    then

        return false

    end

    if Friendly(rig.Model) then

        return false

    end

    local point =

        AimPoint(rig)

    if not point then

        return false

    end

    if not Camera then

        return false

    end

    if

        (

            point

            -

            Camera.CFrame.Position

        ).Magnitude < 3

    then

        return false

    end

    local screen =

        ToScreen(point)

    if not screen then

        return false

    end

    if

        (

            screen

            -

            Center()

        ).Magnitude

        >

        Config.FOV

    then

        return false

    end

    if

        Config.WallCheck

        and

        not Visible(rig)

    then

        return false

    end

    return true

end

--==============================================================

-- FIND TARGET

--==============================================================

local function FindTarget()

    if CurrentTarget then

        if

            CurrentTarget.Model

            and

            CurrentTarget.Model.Parent

        then

            -- Revalida o alvo durante o lock.
            -- Se entrar atrás de parede / sair do FOV / ficar inválido,
            -- o lock é solto imediatamente.

            if CanAcquireTarget(CurrentTarget) then

                return CurrentTarget

            end

            ResetTarget()

            return nil

        end

        ResetTarget()

        return nil

    end

    if

        Config.HardTargetLock

        and

        SelectedThisHold

    then

        return nil

    end

    local center =

        Center()

    local bestTarget = nil

    local bestDistance =

        Config.FOV

    for _,rig in pairs(Rigs) do

        if CanAcquireTarget(rig) then

            local point =

                AimPoint(rig)

            local screen =

                ToScreen(point)

            if screen then

                local distance =

                    (

                        screen

                        -

                        center

                    ).Magnitude

                if

                    distance

                    <

                    bestDistance

                then

                    bestDistance =

                        distance

                    bestTarget =

                        rig

                end

            end

        end

    end

    if bestTarget then

        CurrentTarget =

            bestTarget

        SelectedThisHold =

            true

        AimSettled =

            false

        SmoothedDelta =

            nil

        AimVelocity =

            Vector2.zero

        LastRawDelta =

            nil

    end

    return CurrentTarget

end

--==============================================================

-- MOUSE REL

--==============================================================

local MouseRelative = nil

pcall(function()

    if

        typeof(mousemoverel)

        ==

        "function"

    then

        MouseRelative =

            mousemoverel

        AimInputMode =

            "MOUSE REL"

    end

end)

pcall(function()

    if MouseRelative then

        return

    end

    if

        ENV

        and

        typeof(ENV.mousemoverel)

        ==

        "function"

    then

        MouseRelative =

            ENV.mousemoverel

        AimInputMode =

            "GENV MOUSE REL"

    end

end)

local VIM = nil

pcall(function()

    VIM =

        game:GetService(

            "VirtualInputManager"

        )

end)

if

    not MouseRelative

    and

    VIM

then

    AimInputMode =

        "VIRTUAL INPUT"

end

if

    not MouseRelative

    and

    not VIM

then

    AimInputMode =

        "SEM API DE MOUSE"

end

--==============================================================

-- SEND MOUSE

--==============================================================

local function SendMouseMove(

    moveX,

    moveY

)

    if

        moveX == 0

        and

        moveY == 0

    then

        return true

    end

    if MouseRelative then

        local ok =

            pcall(

                MouseRelative,

                moveX,

                moveY

            )

        if ok then

            AimInputMode =

                "MOUSE REL"

            return true

        end

    end

    if VIM then

        local mouse =

            UIS:GetMouseLocation()

        local ok =

            pcall(function()

                VIM:SendMouseMoveEvent(

                    mouse.X + moveX,

                    mouse.Y + moveY,

                    game

                )

            end)

        if ok then

            AimInputMode =

                "VIRTUAL INPUT"

            return true

        end

    end

    AimInputMode =

        "SEM API DE MOUSE"

    return false

end

--==============================================================

-- STABLE MOVE AIM

--==============================================================

local function MoveTowards(current, target, maxDelta)

    local delta = target - current

    local magnitude = delta.Magnitude

    if magnitude <= maxDelta or magnitude == 0 then

        return target

    end

    return current + (delta / magnitude) * maxDelta

end

local function RoundInt(value)

    if value >= 0 then

        return math.floor(value + 0.5)

    end

    return math.ceil(value - 0.5)

end

local function MoveAim(

    dx,

    dy,

    dt

)

    local frameDT =

        math.clamp(

            dt or 0.016,

            0.001,

            0.05

        )

    local rawDelta =

        Vector2.new(

            dx,

            dy

        )

    local rawDistance =

        rawDelta.Magnitude

    --==========================================================

    -- LOCKED / DEADZONE

    --==========================================================

    if AimSettled then

        if rawDistance <= Config.AimReacquire then

            AimVelocity = Vector2.zero

            SmoothedDelta = rawDelta

            LastRawDelta = rawDelta

            return true

        end

        AimSettled = false

    end

    if rawDistance <= Config.AimDeadzone then

        AimSettled = true

        AimVelocity = Vector2.zero

        SmoothedDelta = rawDelta

        LastRawDelta = rawDelta

        return true

    end

    --==========================================================

    -- FILTER TARGET ERROR
    --==========================================================

    if not SmoothedDelta then

        SmoothedDelta = rawDelta

    else

        local filterAlpha =

            1

            -

            math.exp(

                -Config.AimTargetFilter

                *

                frameDT

            )

        filterAlpha =

            math.clamp(

                filterAlpha,

                0.08,

                0.55

            )

        SmoothedDelta =

            SmoothedDelta:Lerp(

                rawDelta,

                filterAlpha

            )

    end

    local filteredDistance =

        SmoothedDelta.Magnitude

    if filteredDistance <= Config.AimDeadzone then

        AimSettled = true

        AimVelocity = Vector2.zero

        LastRawDelta = rawDelta

        return true

    end

    --==========================================================

    -- RESPONSE PROFILE

    --==========================================================

    local response

    local maxStep

    local errorFactor

    if filteredDistance >= Config.AimFarRadius then

        response = Config.AimFarResponse

        maxStep = Config.AimFarMaxStep

        errorFactor = Config.AimFarErrorFactor

    elseif filteredDistance >= Config.AimMidRadius then

        response = Config.AimMidResponse

        maxStep = Config.AimMidMaxStep

        errorFactor = Config.AimMidErrorFactor

    elseif filteredDistance >= Config.AimNearRadius then

        response = Config.AimNearResponse

        maxStep = Config.AimNearMaxStep

        errorFactor = Config.AimNearErrorFactor

    else

        response = Config.AimMicroResponse

        maxStep = Config.AimMicroMaxStep

        errorFactor = 0.32

    end

    local strength =

        math.clamp(

            Config.AimStrength,

            Config.AimStrengthMin,

            Config.AimStrengthMax

        )

    -- Strength increases pull without multiplying raw cursor jumps.

    local strengthResponse =

        0.72 + strength * 0.42

    local strengthStep =

        0.70 + strength * 0.36

    response =

        response

        *

        strengthResponse

    maxStep =

        math.min(

            maxStep * strengthStep,

            Config.AimHardMaxStep

        )

    local alpha =

        1

        -

        math.exp(

            -response

            *

            frameDT

        )

    alpha =

        math.clamp(

            alpha,

            0.03,

            0.42

        )

    local desiredMove =

        SmoothedDelta

        *

        alpha

    --==========================================================

    -- NO OVERSHOOT / NO TELEPORT
    --==========================================================

    local allowedByError =

        math.max(

            0,

            filteredDistance - Config.AimDeadzone

        )

        *

        errorFactor

    local allowedStep =

        math.min(

            maxStep,

            allowedByError,

            Config.AimHardMaxStep

        )

    if

        desiredMove.Magnitude > allowedStep

        and

        desiredMove.Magnitude > 0

    then

        desiredMove =

            desiredMove.Unit

            *

            allowedStep

    end

    --==========================================================

    -- REVERSAL BRAKE
    --==========================================================

    if LastRawDelta and filteredDistance < Config.AimMidRadius then

        if

            math.sign(rawDelta.X) ~= 0

            and

            math.sign(LastRawDelta.X) ~= 0

            and

            math.sign(rawDelta.X) ~= math.sign(LastRawDelta.X)

        then

            AimVelocity =

                Vector2.new(

                    0,

                    AimVelocity.Y

                )

        end

        if

            math.sign(rawDelta.Y) ~= 0

            and

            math.sign(LastRawDelta.Y) ~= 0

            and

            math.sign(rawDelta.Y) ~= math.sign(LastRawDelta.Y)

        then

            AimVelocity =

                Vector2.new(

                    AimVelocity.X,

                    0

                )

        end

    end

    LastRawDelta = rawDelta

    --==========================================================

    -- ACCELERATION LIMIT
    --==========================================================

    local frameScale =

        math.clamp(

            frameDT * 60,

            0.50,

            1.50

        )

    local maxVelocityChange =

        Config.AimAcceleration

        *

        frameScale

        *

        (0.85 + strength * 0.15)

    AimVelocity =

        MoveTowards(

            AimVelocity,

            desiredMove,

            maxVelocityChange

        )

    if AimVelocity.Magnitude > Config.AimHardMaxStep then

        AimVelocity =

            AimVelocity.Unit

            *

            Config.AimHardMaxStep

    end

    --==========================================================

    -- INTEGER STEP
    --
    -- no residual accumulator: prevents +/-1px vibration
    --==========================================================

    local moveX =

        RoundInt(

            AimVelocity.X

        )

    local moveY =

        RoundInt(

            AimVelocity.Y

        )

    if filteredDistance < Config.AimNearRadius then

        if math.abs(moveX) <= 1 then

            moveX = 0

        end

        if math.abs(moveY) <= 1 then

            moveY = 0

        end

    end

    moveX =

        math.clamp(

            moveX,

            -Config.AimHardMaxStep,

            Config.AimHardMaxStep

        )

    moveY =

        math.clamp(

            moveY,

            -Config.AimHardMaxStep,

            Config.AimHardMaxStep

        )

    return

        SendMouseMove(

            moveX,

            moveY

        )

end

--==============================================================

-- AIM LOOP

--==============================================================

local function AimLoop(dt)

    if Destroyed then

        return

    end

    if not RefreshCamera() then

        return

    end

    if

        not Config.Aim

        or

        not RMB

    then

        ResetTarget()

        return

    end

    local target =

        FindTarget()

    if not target then

        return

    end

    if

        not target.Model

        or

        not target.Model.Parent

    then

        ResetTarget()

        return

    end

    if

        Config.WallCheck

        and

        not Visible(target)

    then

        ResetTarget()

        return

    end

    local point =

        AimPoint(target)

    if not point then

        ResetTarget()

        return

    end

    local screen =

        ToScreen(point)

    if not screen then

        return

    end

    local center =

        Center()

    local delta =

        screen

        -

        center

    MoveAim(

        delta.X,

        delta.Y,

        dt

    )

end

--==============================================================

-- AIM PRIORITY

--==============================================================

RunService:

BindToRenderStep(

    "SARTEX_FRONTLINES_AIM",

    Enum.RenderPriority.Camera.Value + 10,

    AimLoop

)

--==============================================================

-- INPUT

--==============================================================

Connect(

    UIS.InputBegan,

    function(input,processed)

        if

            input.UserInputType

            ==

            Enum.UserInputType.MouseButton2

        then

            RMB = true

            ResetTarget()

        end

        if

            not processed

            and

            input.KeyCode

            ==

            Enum.KeyCode.P

        then

            Panel.Visible =

                not Panel.Visible

        end

    end

)

Connect(

    UIS.InputEnded,

    function(input)

        if

            input.UserInputType

            ==

            Enum.UserInputType.MouseButton2

        then

            RMB = false

            ResetTarget()

        end

    end

)

--==============================================================

-- ESP

--==============================================================

local function NewLine()

    local l =

        Instance.new("Frame")

    l.AnchorPoint =

        Vector2.new(

            0,

            0.5

        )

    l.BorderSizePixel = 0

    l.Visible = false

    l.ZIndex = 30

    l.Parent = GUI

    return l

end

local function DrawLine(

    line,

    a,

    b,

    color,

    thickness

)

    if not line then

        return

    end

    local d =

        b - a

    line.Position =

        UDim2.fromOffset(

            a.X,

            a.Y

        )

    line.Size =

        UDim2.fromOffset(

            d.Magnitude,

            thickness or 2

        )

    line.Rotation =

        math.deg(

            math.atan2(

                d.Y,

                d.X

            )

        )

    line.BackgroundColor3 =

        color

    line.Visible = true

end

local function CreateVisual(rig)

    local model =

        rig.Model

    if Visuals[model] then

        return Visuals[model]

    end

    local box =

        Instance.new("Frame")

    box.BackgroundTransparency = 1

    box.BorderSizePixel = 0

    box.Visible = false

    box.ZIndex = 20

    box.Parent = GUI

    local stroke =

        Instance.new("UIStroke")

    stroke.Thickness = 1.5

    stroke.Parent = box

    local head =

        Instance.new("Frame")

    head.AnchorPoint =

        Vector2.new(

            0.5,

            0.5

        )

    head.Size =

        UDim2.fromOffset(

            8,

            8

        )

    head.BorderSizePixel = 0

    head.Visible = false

    head.ZIndex = 31

    head.Parent = GUI

    local hc =

        Instance.new("UICorner")

    hc.CornerRadius =

        UDim.new(

            1,

            0

        )

    hc.Parent = head

    local distance =

        Instance.new("TextLabel")

    distance.Size =

        UDim2.fromOffset(

            130,

            18

        )

    distance.BackgroundTransparency = 1

    distance.Font =

        Enum.Font.GothamBold

    distance.TextSize = 10

    distance.TextStrokeTransparency = 0.15

    distance.Visible = false

    distance.ZIndex = 40

    distance.Parent = GUI

    local highlight =

        Instance.new("Highlight")

    highlight.Adornee =

        model

    highlight.DepthMode =

        Enum.HighlightDepthMode.AlwaysOnTop

    highlight.FillTransparency =

        0.82

    highlight.OutlineTransparency =

        0

    highlight.Enabled =

        false

    highlight.Parent =

        model

    local skeleton = {}

    for i = 1,24 do

        skeleton[i] =

            NewLine()

    end

    local corners = {}

    for i = 1,8 do

        corners[i] =

            NewLine()

    end

    local v = {

        Box = box,

        Stroke = stroke,

        Head = head,

        Distance = distance,

        Highlight = highlight,

        Skeleton = skeleton,

        Corners = corners

    }

    Visuals[model] = v

    return v

end

local function HideVisual(v)

    v.Box.Visible = false

    v.Head.Visible = false

    v.Distance.Visible = false

    v.Highlight.Enabled = false

    for _,l in ipairs(

        v.Skeleton

    ) do

        l.Visible = false

    end

    for _,l in ipairs(

        v.Corners

    ) do

        l.Visible = false

    end

end

local function GetBox(rig)

    local hp =

        BonePosition(

            rig.Head

        )

    local rp =

        BonePosition(

            rig.Root

        )

    if

        not hp

        or

        not rp

    then

        return nil

    end

    local top =

        ToScreen(

            hp

            +

            Vector3.new(

                0,

                0.35,

                0

            )

        )

    local bottom =

        ToScreen(

            rp

            -

            Vector3.new(

                0,

                0.45,

                0

            )

        )

    if

        not top

        or

        not bottom

    then

        return nil

    end

    local h =

        math.abs(

            bottom.Y

            -

            top.Y

        )

    if h < 8 then

        return nil

    end

    local w =

        h * 0.48

    local x =

        (

            (

                top.X

                +

                bottom.X

            )

            /

            2

        )

        -

        (

            w / 2

        )

    return

        x,

        top.Y,

        w,

        h

end

local function DrawCorners(

    v,

    x,

    y,

    w,

    h,

    color

)

    local len =

        math.clamp(

            math.min(

                w,

                h

            )

            *

            0.25,

            6,

            20

        )

    local c =

        v.Corners

    DrawLine(

        c[1],

        Vector2.new(x,y),

        Vector2.new(x+len,y),

        color,

        2

    )

    DrawLine(

        c[2],

        Vector2.new(x,y),

        Vector2.new(x,y+len),

        color,

        2

    )

    DrawLine(

        c[3],

        Vector2.new(x+w-len,y),

        Vector2.new(x+w,y),

        color,

        2

    )

    DrawLine(

        c[4],

        Vector2.new(x+w,y),

        Vector2.new(x+w,y+len),

        color,

        2

    )

    DrawLine(

        c[5],

        Vector2.new(x,y+h),

        Vector2.new(x+len,y+h),

        color,

        2

    )

    DrawLine(

        c[6],

        Vector2.new(x,y+h-len),

        Vector2.new(x,y+h),

        color,

        2

    )

    DrawLine(

        c[7],

        Vector2.new(x+w-len,y+h),

        Vector2.new(x+w,y+h),

        color,

        2

    )

    DrawLine(

        c[8],

        Vector2.new(x+w,y+h-len),

        Vector2.new(x+w,y+h),

        color,

        2

    )

end

local function DrawSkeleton(

    rig,

    v,

    color

)

    local index = 1

    local function Link(a,b)

        if

            not a

            or

            not b

            or

            index > #v.Skeleton

        then

            return

        end

        local ap =

            BonePosition(a)

        local bp =

            BonePosition(b)

        if

            not ap

            or

            not bp

        then

            return

        end

        local a2 =

            ToScreen(ap)

        local b2 =

            ToScreen(bp)

        if

            not a2

            or

            not b2

        then

            return

        end

        DrawLine(

            v.Skeleton[index],

            a2,

            b2,

            color,

            2

        )

        index =

            index + 1

    end

    Link(rig.Head,rig.Neck)

    Link(rig.Neck,rig.Chest)

    Link(rig.Chest,rig.Spine2)

    Link(rig.Spine2,rig.Spine1)

    Link(rig.Spine1,rig.Root)

    Link(rig.Chest,rig.ScapulaL)

    Link(rig.ScapulaL,rig.ShoulderL)

    Link(rig.ShoulderL,rig.ElbowL)

    Link(rig.ElbowL,rig.WristL)

    Link(rig.Chest,rig.ScapulaR)

    Link(rig.ScapulaR,rig.ShoulderR)

    Link(rig.ShoulderR,rig.ElbowR)

    Link(rig.ElbowR,rig.WristR)

    Link(rig.Root,rig.HipL)

    Link(rig.HipL,rig.KneeL)

    Link(rig.KneeL,rig.AnkleL)

    Link(rig.Root,rig.HipR)

    Link(rig.HipR,rig.KneeR)

    Link(rig.KneeR,rig.AnkleR)

end

local function GetESPColor(rig)

    if

        RMB

        and

        CurrentTarget == rig

    then

        return Colors.Red

    end

    if

        Config.VisibleColor

        and

        Config.WallCheck

        and

        Visible(rig)

    then

        return Colors.Green

    end

    return Colors.Gold

end

local function UpdateESP(rig)

    local v =

        CreateVisual(rig)

    HideVisual(v)

    if not Config.ESP then

        return

    end

    if Friendly(rig.Model) then

        return

    end

    local x,y,w,h =

        GetBox(rig)

    if not x then

        return

    end

    local color =

        GetESPColor(rig)

    local style =

        Config.ESPStyle

    if style == "FULL" then

        DrawCorners(

            v,

            x,

            y,

            w,

            h,

            color

        )

        DrawSkeleton(

            rig,

            v,

            color

        )

        local hp =

            BonePosition(

                rig.Head

            )

        local sp =

            ToScreen(hp)

        if sp then

            v.Head.Position =

                UDim2.fromOffset(

                    sp.X,

                    sp.Y

                )

            v.Head.BackgroundColor3 =

                color

            v.Head.Visible =

                true

        end

    elseif style == "SKELETON" then

        DrawSkeleton(

            rig,

            v,

            color

        )

    elseif style == "CORNER" then

        DrawCorners(

            v,

            x,

            y,

            w,

            h,

            color

        )

    elseif style == "BOX" then

        v.Box.Position =

            UDim2.fromOffset(

                x,

                y

            )

        v.Box.Size =

            UDim2.fromOffset(

                w,

                h

            )

        v.Stroke.Color =

            color

        v.Box.Visible =

            true

    elseif style == "HEAD" then

        local hp =

            BonePosition(

                rig.Head

            )

        local sp =

            ToScreen(hp)

        if sp then

            v.Head.Position =

                UDim2.fromOffset(

                    sp.X,

                    sp.Y

                )

            v.Head.BackgroundColor3 =

                color

            v.Head.Visible =

                true

        end

    elseif style == "HIGHLIGHT" then

        v.Highlight.FillColor =

            color

        v.Highlight.OutlineColor =

            color

        v.Highlight.Enabled =

            true

    end

    if Config.ShowDistance then

        local hp =

            BonePosition(

                rig.Head

            )

        if hp then

            local dist =

                (

                    Camera.CFrame.Position

                    -

                    hp

                ).Magnitude

            v.Distance.Position =

                UDim2.fromOffset(

                    x

                    +

                    w/2

                    -

                    65,

                    y

                    +

                    h

                    +

                    3

                )

            v.Distance.Text =

                tostring(

                    math.floor(

                        dist

                    )

                )

                ..

                " studs"

            v.Distance.TextColor3 =

                color

            v.Distance.Visible =

                true

        end

    end

end

--==============================================================

-- ESP LOOP

--==============================================================

local ESPAccumulator = 0

Connect(

    RunService.RenderStepped,

    function(dt)

        if Destroyed then

            return

        end

        RefreshCamera()

        if not Camera then

            return

        end

        local c =

            Center()

        FOVCircle.Position =

            UDim2.fromOffset(

                c.X,

                c.Y

            )

        FOVCircle.Size =

            UDim2.fromOffset(

                Config.FOV * 2,

                Config.FOV * 2

            )

        FOVCircle.Visible =

            Config.ShowFOV

            and

            Config.Aim

        FOVStroke.Color =

            CurrentTarget

            and

            Colors.Red

            or

            Colors.Gold

        ESPAccumulator =

            ESPAccumulator

            +

            dt

        local interval =

            1

            /

            math.clamp(

                Config.ESPFPS,

                10,

                120

            )

        if

            ESPAccumulator

            >=

            interval

        then

            ESPAccumulator = 0

            for model,rig in pairs(Rigs) do

                if model.Parent then

                    UpdateESP(rig)

                else

                    RemoveRig(model)

                end

            end

        end

        local count = 0

        for _ in pairs(Rigs) do

            count =

                count + 1

        end

        Status.Text =

            "RIGS: "

            ..

            count

            ..

            "    RMB: "

            ..

            tostring(RMB)

            ..

            "\nTARGET: "

            ..

            (

                CurrentTarget

                and

                "CHEST • FAST WALL LOCK"

                or

                "NONE"

            )

            ..

            "\nAIM INPUT: "

            ..

            tostring(

                AimInputMode

            )

            ..

            "\nFOV: "

            ..

            tostring(

                Config.FOV

            )

            ..

            "    FORCE: "

            ..

            string.format(

                "%.2f",

                Config.AimStrength

            )

        AimButton.Text =

            "AIMBOT: "

            ..

            (

                Config.Aim

                and

                "ON"

                or

                "OFF"

            )

        WallButton.Text =

            "WALL CHECK: "

            ..

            (

                Config.WallCheck

                and

                "ON"

                or

                "OFF"

            )

        TeamButton.Text =

            "TEAM CHECK: "

            ..

            (

                Config.TeamCheck

                and

                "ON"

                or

                "OFF"

            )

        ESPButton.Text =

            "ESP: "

            ..

            (

                Config.ESP

                and

                "ON"

                or

                "OFF"

            )

        GhostButton.Text =

            "UNDERGROUND GHOST: "

            ..

            (

                Config.UndergroundGhost

                and

                "ON"

                or

                "OFF"

            )

        GhostDepthDownButton.Text =

            "GHOST DEPTH -1  ["

            ..

            string.format(

                "%.0f",

                Config.UndergroundDepth

            )

            ..

            "]"

        GhostDepthUpButton.Text =

            "GHOST DEPTH +1  ["

            ..

            string.format(

                "%.0f",

                Config.UndergroundDepth

            )

            ..

            "]"

        StyleButton.Text =

            "ESP STYLE: "

            ..

            Config.ESPStyle

        StrengthDownButton.Text =

            "PUXADA -0.10  [" .. string.format("%.2f", Config.AimStrength) .. "]"

        StrengthUpButton.Text =

            "PUXADA +0.10  [" .. string.format("%.2f", Config.AimStrength) .. "]"

    end

)

--==============================================================

-- DRAG

--==============================================================

local Dragging = false

local DragStart = nil

local StartPosition = nil

Connect(

    Title.InputBegan,

    function(input)

        if

            input.UserInputType

            ==

            Enum.UserInputType.MouseButton1

        then

            Dragging = true

            DragStart =

                input.Position

            StartPosition =

                Panel.Position

        end

    end

)

Connect(

    UIS.InputEnded,

    function(input)

        if

            input.UserInputType

            ==

            Enum.UserInputType.MouseButton1

        then

            Dragging = false

        end

    end

)

Connect(

    UIS.InputChanged,

    function(input)

        if

            not Dragging

            or

            input.UserInputType

            ~=

            Enum.UserInputType.MouseMovement

        then

            return

        end

        local delta =

            input.Position

            -

            DragStart

        Panel.Position =

            UDim2.new(

                StartPosition.X.Scale,

                StartPosition.X.Offset

                +

                delta.X,

                StartPosition.Y.Scale,

                StartPosition.Y.Offset

                +

                delta.Y

            )

    end

)

--==============================================================

-- CLEANUP

--==============================================================

local function Cleanup()

    if Destroyed then

        return

    end

    if Config.UndergroundGhost then

        GhostSetEnabled(false)

    end

    Destroyed = true

    pcall(function()

        RunService:

        UnbindFromRenderStep(

            "SARTEX_FRONTLINES_AIM"

        )

    end)

    pcall(function()

        RunService:UnbindFromRenderStep(

            "SARTEX_FRONTLINES_GHOST"

        )

    end)

    for _,c in ipairs(Connections) do

        pcall(function()

            c:Disconnect()

        end)

    end

    for model in pairs(Visuals) do

        RemoveVisual(model)

    end

    pcall(function()

        GUI:Destroy()

    end)

    ENV.SARTEX_FRONTLINES_CLEANUP =

        nil

end

ENV.SARTEX_FRONTLINES_CLEANUP =

    Cleanup

--==============================================================

-- READY

--==============================================================

print("==========================================")

print("SARTEX FRONTLINES V2.3 WALLCHECK FAST LOCK")

print("RMB = AIM")

print("P = PAINEL")

print("CHEST FAST WALL LOCK = ON")

print("AIM FORCE DEFAULT = 1.00")

print("WALLCHECK DEFAULT = ON")

print("UNDERGROUND GHOST = READY")

print("GHOST DEPTH DEFAULT = 8 STUDS")

print("STRONG FAR PULL = ON")

print("STRONG MID PULL = ON")

print("NEAR BRAKE = ON")

print("ANTI OVERSHOOT = ON")

print("HARD TARGET LOCK = ON")

print("PULL BUTTONS = -0.10 / +0.10")

print("==========================================")