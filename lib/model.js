(function() {
  var CANNON, Factory, Physics, Robot,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  CANNON = require('cannon');

  Physics = (function() {
    function Physics() {
      this.update = __bind(this.update, this);
      this.addBody = __bind(this.addBody, this);
      this.world = new CANNON.World();
      this.world.gravity.set(0, 0, 0);
      this.world.broadphase = new CANNON.NaiveBroadphase();
      this.world.solver.iterations = 10;
      this.timeStep = 1 / 60;
    }

    Physics.prototype.addBody = function() {
      this.shape = new CANNON.Box(new CANNON.Vec3(1, 1, 1));
      this.mass = 1;
      this.body = new CANNON.RigidBody(this.mass, this.shape);
      this.body.angularVelocity.set(0, 10, 0);
      this.world.add(this.body);
      return this.body;
    };

    Physics.prototype.update = function(mesh) {
      this.world.step(this.timeStep);
      this.body.position.copy(mesh.position);
      return this.body.quaternion.copy(mesh.quaternion);
    };

    return Physics;

  })();

  Robot = (function() {
    function Robot(src) {
      this.compute = __bind(this.compute, this);
      this.setVelocity = __bind(this.setVelocity, this);
    }

    Robot.prototype.setVelocity = function(x, y, z) {
      return console.log("setting velocity..");
    };

    Robot.prototype.compute = function(x, y, z) {
      var a, b, c, _ref;
      _ref = [0, 0, 0], a = _ref[0], b = _ref[1], c = _ref[2];
      mutable(function() {
        a = x * 1;
        b = y * 1;
        return c = z * 1;
      });
      return this.setVelocity(a, b, c);
    };

    return Robot;

  })();

  Factory = (function() {
    function Factory() {
      this.variants = {};
    }

    Factory.prototype.select = function(cb) {
      var robot, src;
      console.log("step 1. get a program");
      src = deck.pick(this.variants);
      robot = new Robot(src);
      return robot.evolve(function() {
        console.log("robot evolved, we can use it");
        return cb(robot);
      });
    };

    Factory.prototype.review = function(robot, score) {
      var src;
      console.log("saving robot");
      src = robot.toString();
      return this.variants[src] = Math.round(score * 1000);
    };

    return Factory;

  })();

  module.exports = Factory;

}).call(this);
