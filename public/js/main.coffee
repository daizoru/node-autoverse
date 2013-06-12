

SKELETON =

  p: [0,0,20]
  Torso:
    p: [0,0,25]
    Neck:
      p: [0,0,28]
      Head:
        p: [0,0,30]
    ShoulderL:
      p: [3,0,25]
      ElbowL:
        p: [6,0,21]
        WristL:
          p: [9,0,18]
    ShoulderR:
      p: [-3,0,25]
      ElbowR:
        p: [-6,0,21]
        WristR: 
          p: [-9,0,18]
  Pelvis:
    p: [0,0,15]
    HipL:
      p: [3,0,13]
      KneeL:
        p: [6,0,10]
        AnkleL: 
          p: [9,0,5]
    HipR:
      p: [-3,0,13]
      KneeR:
        p: [-6,0,10]
        AnkleR: 
          p: [-9,0,5]

class Physics

  constructor: ->
    # CANNONBALL!1!!

    @world = new CANNON.World()
    #@world.gravity.set 0, 0, -10
    @world.gravity.set 0, 0, -9.82
    @world.broadphase = new CANNON.NaiveBroadphase()
    @world.solver.iterations = 10

    @timeStep = 1 / 60

  makeScene: =>

    # PLANE
    p = new CANNON.Vec3(0,0,1)
    @groundShape = new CANNON.Plane(p)
    @ground = new CANNON.RigidBody 0, @groundShape
    @ground.position.set 0,0,1
    @world.add @ground

    # STEPS
 
    @stepsShape = new CANNON.Box(new CANNON.Vec3(10, 10, 2))
    @stepsMass = 10.0
    @steps = new CANNON.RigidBody @stepsMass, @stepsShape
    @steps.position.set 0, 0, 3
    @world.add @steps



  
    constraints = []
    nodes = []


    ###
    makeBone = ({radius, length, mass}) =>

      boneShape = new CANNON.Compound()


      boneCenter = new CANNON.Box(new CANNON.Vec3(radius,radius,length))
      boneJoint = new CANNON.Sphere(radius * 0.8)

      boneShape.addChild boneCenter, new CANNON.Vec3  0,  0,  0
      boneShape.addChild boneJoint,  new CANNON.Vec3  0,  0, - (length * 0.5 + radius * 0.5)
      boneShape.addChild boneJoint,  new CANNON.Vec3  0,  0,  + (length * 0.5 + radius * 0.5)

      boneBody = new CANNON.RigidBody mass, boneShape
      boneBody
    ###

    makeNode = ({name, radius, mass,position}) =>
      nodeShape = new CANNON.Sphere radius
      nodeBody = new CANNON.RigidBody mass, nodeShape
      nodeBody.position.set position[0], position[1], position[2]
      nodes.push nodeBody
      nodeBody.name = name
      nodeBody

    iterate = (tree,name,parent=no) ->

      node = makeNode name: name, radius: 1.0, mass: 4.0, position: tree.p

      # TODO use current (initial) distance as constraint
      if parent
        c = new CANNON.DistanceConstraint parent, node, 1
        c.name = "#{parent.name} -> #{node.name}"
        #constraints.push c


      for name, child of tree
        continue if name is 'p'
        iterate child, name, node

    iterate SKELETON, "Root"

    console.log "nodes:"
    console.dir nodes
    
    console.log "constraints:"
    console.dir constraints

    for n in nodes
      @world.add n
    for c in constraints
      1#@world.add c
    #@world.add constraints[3]

    @nodes = nodes

    nodes


  update: ({steps, nodes}) =>
    
    # Step the physics world
    @world.step @timeStep

    @steps.position.copy        steps.position
    @steps.quaternion.copy      steps.quaternion

    for i in [0...@nodes.length]
      @nodes[i].position.copy nodes[i].position
      @nodes[i].quaternion.copy nodes[i].quaternion

class Scene
  constructor: ({debug}) ->

    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000)
    camera.position.z = 12
    camera.position.y = - 20
    

    #camera = new THREE.PerspectiveCamera( 25, width / height, 50, 1e7 );

    scene = new THREE.Scene()

    scene.add camera

    #@scene.fog = new THREE.Fog 0x050505, 400, 1000
    # white fog
    scene.fog = new THREE.Fog 0xffffff, 1000, 4000

    ambientLight = new THREE.AmbientLight 0x888888
    scene.add ambientLight
 
    ##@scene.add( new THREE.AmbientLight( 0x222222 ) )

    ###
    light = new THREE.DirectionalLight 0xffffff, 2.25
    light.position.set -200, 450, 500

    light.castShadow = yes
    light.shadowMapWidth = 1024
    light.shadowMapHeight = 1024
    light.shadowMapDarkness = 0.95
    #light.shadowCameraVisible = true;

    light.shadowCascade = yes
    light.shadowCascadeCount = 3
    light.shadowCascadeNearZ = [ -1.000, 0.995, 0.998 ]
    light.shadowCascadeFarZ  = [  0.995, 0.998, 1.000 ]
    light.shadowCascadeWidth = [ 1024, 1024, 1024 ]
    light.shadowCascadeHeight = [ 1024, 1024, 1024 ]

    @scene.add light
   
    ###

    light = new THREE.SpotLight 0xffffff, 2, 1000
    light.position.set  200, 500, 500

    light.castShadow = true
    light.shadowMapWidth = 1024
    light.shadowMapHeight = 1024
    light.shadowMapDarkness = 0.95
    #@light.shadowCameraVisible = true;

    scene.add light

    ###
    light2 = new THREE.SpotLight 0xffffff, 1.5, 500
    light2.position.set -10, 35, 25

    light2.castShadow = true
    light2.shadowMapWidth = 1024
    light2.shadowMapHeight = 1024
    light2.shadowMapDarkness = 0.95
    #light.shadowCameraVisible = true;

    @scene.add light2
    ###
 
    config =
      useWireframe: no



    groundGeometry = new THREE.PlaneGeometry  100, 100, 10, 10
    groundTexture = THREE.ImageUtils.loadTexture "http://localhost:3000/textures/grasslight-big.jpg" 
    
    groundMaterial = new THREE.MeshPhongMaterial
      #color: 0xffffff
      map: groundTexture # TODO uncomment
      perPixel: yes
 
    if debug
      groundMaterial = new THREE.MeshPhongMaterial
        color: 0x107702
        perPixel: yes
        opacity: 1.0
        wireframe: config.useWireframe

   
    ground = new THREE.Mesh groundGeometry, groundMaterial
    ground.position.z = 2.0
    ground.rotation.x = Math.PI / 2.0
    unless debug
      ground.material.map.repeat.set 8, 8
      ground.material.map.wrapS = ground.material.map.wrapT = THREE.RepeatWrapping
      ground.receiveShadow = yes
    scene.add ground


    nodeTexture = THREE.ImageUtils.loadTexture "/textures/dirty-painted-wood-texture-01.jpg"
    nodeMaterial = new THREE.MeshPhongMaterial
      #color: 0x660210
      map: nodeTexture
      perPixel: yes
      opacity: 1.0
    if debug
      nodeMaterial = new THREE.MeshBasicMaterial
        color: 0x660210
        opacity: 0.4
        wireframe: yes #config.useWireframe


    # steps are a bit special
    stepsGeometry = new THREE.CubeGeometry 10, 10, 2
    steps = new THREE.Mesh stepsGeometry, nodeMaterial
    steps.useQuaternion = true
    steps.scale.x = 2.0
    steps.scale.y = 2.0
    steps.scale.z = 2.0
    scene.add steps

    
    nodes = []

    add = (element) ->
      scene.add element
      nodes.push element
      element

    make = (g) ->
      o = new THREE.Mesh g, material
      o.useQuaternion = true
      add o

    ###
    makeBone = ({radius,length}) =>

      coreGeom = new THREE.CubeGeometry radius, radius, length
      core = new THREE.Mesh coreGeom, @material

      jointGeom1 = new THREE.SphereGeometry radius * 0.8, 6, 6
      joint1 = new THREE.Mesh jointGeom1, @material
      joint1.position.z = + length * 0.5 + radius * 0.5
      core.add joint1

      jointGeom2 = new THREE.SphereGeometry radius * 0.8, 6, 6
      joint2 = new THREE.Mesh jointGeom2, @material
      joint2.position.z = -length * 0.5 - radius * 0.5
      core.add joint2

      core.useQuaternion = true

      add core
    ###

    makeNode = ({radius}) ->
      g = new THREE.SphereGeometry radius, 8, 8
      n = new THREE.Mesh g, nodeMaterial
      n.useQuaternion = true
      add n


    iterate = (tree,parent=no) ->
      node = makeNode radius: 0.1, mass: 10.0

      #if parent
      #  # TODO add cylinder?
      #  c = new CANNON.DistanceConstraint parent, node, 1
      #  constraints.push c

      for name, child of tree
        continue if name is 'p'
        iterate child, node

    iterate SKELETON

    console.log "nodes:"
    console.dir nodes

    for node in nodes
      node.scale.x = 2.0
      node.scale.y = 2.0
      node.scale.z = 2.0


    renderer = new THREE.WebGLRenderer
      antialias: true
      clearColor: scene.fog.color
    renderer.setSize window.innerWidth, window.innerHeight
    document.body.appendChild renderer.domElement

    renderer.setClearColor scene.fog.color, 1
    renderer.gammaInput = yes
    renderer.gammaOutput = yes
    renderer.shadowMapEnabled = yes
    #@renderer.shadowMapCullFrontFaces = yes

    renderer.shadowMapCascade = yes
    #renderer.shadowMapDebug = true;

    controls = new THREE.TrackballControls camera, renderer.domElement

    controls.rotateSpeed = 0.9
    controls.zoomSpeed = 0.2
    controls.panSpeed = 0.2

    controls.noZoom = false
    controls.noPan = false

    controls.staticMoving = false
    controls.dynamicDampingFactor = 0.3

    controls.minDistance = 10
    controls.maxDistance = 100

    controls.keys = [ 65, 83, 68 ] # [ rotateKey, zoomKey, panKey ]

    # make some objects public
    @steps = steps
    @nodes = nodes
    @renderer = renderer
    @scene = scene
    @camera = camera
    @controls = controls


  update: =>
    @controls.update()
    #@renderer.clear()
    @renderer.render @scene, @camera

class Robot
 
  constructor: (@src="") ->

    # load the source, ecapsulate it for safety
    #@kernel = eval ""

class Trainer

  constructor: ->
    @individuals = {}

  # evaluate the robot for N seconds
  evaluate: (options={}) ->
    opts =
      robot: no
      duration: 3000
      resolution: 1000
      onComplete: (robot, score) -> console.log "terminated.. robot: #{robot}, score: #{score}"
    for k, v of options
      opts[k] = v

    # measure the average bot height
    sumHeights = 0
    running = yes
    measure = ->
      currentHeight = 0#opts.robot.body.head.position.z
      sumHeights += currentHeight
      if running
        delay opts.resolution, measure
    measure()
    delay opts.duration, -> 
      running = no
      score = sumHeights
      opts.onComplete opts.robot, score


class Factory

  constructor: ->

  select: (cb) -> async ->
    # TODO download from the server
    src = """var a = 0;"""
    robot = new Robot src
    cb robot

  review: (robot, score) ->
    # read robot source code and send back to server
    console.log "reviewing robot + score: "
    console.log "robot: #{robot}"
    console.log "score: #{score}"

class Main 

  constructor: ->

    @physics = new Physics()
    @scene = new Scene
      debug: yes

  animate: =>
    requestAnimationFrame @animate
    @physics.update 
      steps: @scene.steps
      nodes: @scene.nodes
    @scene.update()

  start: =>
    @animate()

$ ->
  
  main = new Main()

  
  factory = new Factory()
  console.log "making robot"

  factory.select (robot) ->
    console.log "made robot"
    # attach robot to scene - for the moment we only look at the body

    main.physics.makeScene()

    # restart the scene
    console.log "starting the scene"
    main.start()
  
    # actually this part should be on the server side
    trainer = new Trainer()
    trainer.evaluate
      robot: robot
      duration: 3000
      resolution: 1000
      onComplete: (robot, score) ->
        factory.review robot, score


