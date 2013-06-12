
CANNON = require 'cannon'

# TODO this code should be designed using the WebGL frontend,
# because it is a bit difficult to debug here
class Physics

  constructor: ->
    # CANNONBALL!1!!

    @world = new CANNON.World()
    @world.gravity.set 0, 0, 0
    @world.broadphase = new CANNON.NaiveBroadphase()
    @world.solver.iterations = 10

    @timeStep = 1 / 60

  addBody: =>
    @shape = new CANNON.Box(new CANNON.Vec3(1, 1, 1))
    @mass = 1
    @body = new CANNON.RigidBody @mass, @shape
    @body.angularVelocity.set 0, 10, 0
    @world.add @body
    @body

  update: (mesh) =>
    
    # Step the physics world
    @world.step @timeStep
    
    # Copy coordinates from Cannon.js to Three.js
    @body.position.copy   mesh.position
    @body.quaternion.copy mesh.quaternion

class Robot

  constructor: (src) ->
    
  setVelocity: (x,y,z) =>
    console.log "setting velocity.."

  compute: (x,y,z) =>

    [a,b,c] = [0,0,0]

    # only what's inside this block will evolve
    mutable ->
      a = x * 1
      b = y * 1
      c = z * 1

    @setVelocity a, b, c

class Factory
  constructor: ->
    @variants = {}

  select: (cb) ->
    console.log "step 1. get a program"
    # good ones have more chances of being picked up
    src = deck.pick @variants
    robot = new Robot src
    robot.evolve ->
      console.log "robot evolved, we can use it"
      cb robot
      
  review: (robot, score) ->
    console.log "saving robot"
    src = robot.toString()
    @variants[src] = Math.round score * 1000

module.exports = Factory