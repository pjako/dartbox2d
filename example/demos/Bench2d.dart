// Copyright 2012 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library Bench2d;
import 'dart:html';
import 'package:box2d/box2d_browser.dart';

class Bench2d {
  static const int CANVAS_WIDTH = 900;
  static const int CANVAS_HEIGHT = 600;

  static const int FRAMES = 256;
  static const int PYRAMID_SIZE = 20; // 40;

  static const num _VIEWPORT_SCALE = 10;

  static const num GRAVITY = -10;

  static const num TIME_STEP = 1/60;
  static const int VELOCITY_ITERATIONS = 10;
  static const int POSITION_ITERATIONS = 10;

  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  ViewportTransform viewport;
  DebugDraw debugDraw;

  World world;

  Bench2d() {
    final gravity = new vec2(0, GRAVITY);
    bool doSleep = true;
    world = new World(gravity, doSleep, new DefaultWorldPool());
  }

  /**
   * Creates the canvas and readies the demo for animation. Must be called
   * before calling runAnimation.
   */
  void initializeAnimation() {
    // Setup the canvas.
    canvas = new Element.tag('canvas');
    canvas.width = CANVAS_WIDTH;
    canvas.height = CANVAS_HEIGHT;
    document.body.nodes.add(canvas);
    ctx = canvas.getContext("2d");

    // Create the viewport transform with the center at extents.
    final extents = new vec2(CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2);
    viewport = new CanvasViewportTransform(extents, extents);
    viewport.scale = _VIEWPORT_SCALE;

    // Create our canvas drawing tool to give to the world.
    debugDraw = new CanvasDraw(viewport, ctx);

    // Have the world draw itself for debugging purposes.
    world.debugDraw = debugDraw;
  }

  void initialize() {
    {
      BodyDef bd = new BodyDef();
      Body ground = world.createBody(bd);

      PolygonShape shape = new PolygonShape();
      shape.setAsEdge(new vec2(-40.0, 0), new vec2(40.0, 0));

      final fixDef = new FixtureDef();
      fixDef.shape = shape;
      fixDef.density = 0;

      ground.createFixture(fixDef);
    }

    {
      num a = .5;
      PolygonShape shape = new PolygonShape();
      shape.setAsBox(a, a);

      final fixDef = new FixtureDef();
      fixDef.shape = shape;
      fixDef.density = 5;

      vec2 x = new vec2(-7.0, 0.75);
      vec2 y = new vec2.zero();
      vec2 deltaX = new vec2(0.5625, 1);
      vec2 deltaY = new vec2(1.125, 0.0);

      for (int i = 0; i < PYRAMID_SIZE; ++i){
        y.copyFrom(x);

        for (int j = i; j < PYRAMID_SIZE; ++j){
          BodyDef bd = new BodyDef();
          bd.type = BodyType.DYNAMIC;
          bd.position.copyFrom(y);
          Body body = world.createBody(bd);
          body.createFixture(fixDef);
          y.add(deltaY);
        }

        x.add(deltaX);
      }
    }
  }

  void step() {
    world.step(TIME_STEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
  }

  void render() {
    step();

    ctx.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    world.drawDebugData();
    window.requestAnimationFrame((num time) { render(); });
  }

  void runAnimation() {
    window.requestAnimationFrame((num time) { render(); });
  }

  void warmup() {
    for (int i = 0; i < FRAMES; ++i) {
      step();
    }
  }

  void bench() {
    Bench2d bench2d = new Bench2d();

    final times = new List<num>(FRAMES);
    for (int i = 0; i < FRAMES; ++i) {
      final watch = new Stopwatch();
      watch.start();
      bench2d.step();
      watch.stop();
      times[i] = watch.elapsedMilliseconds;
      print(times[i]);
    }

    num total = 0;
    for (int i = 0; i < FRAMES; ++i) total += times[i];
    print(total);
  }
}

void main() {
  final bench2d = new Bench2d();
  bench2d.initialize();

/*
  bench.initializeAnimation();
  bench.runAnimation();
*/

  bench2d.warmup();
  bench2d.bench();
}

