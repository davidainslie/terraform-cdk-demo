package com.mycompany.app;

import java.util.Collections;
import com.hashicorp.cdktf.App;
import com.hashicorp.cdktf.TerraformStack;
import imports.docker.*;
import software.constructs.Construct;

public class Main extends TerraformStack {
  public Main(final Construct scope, final String id) {
    super(scope, id);

    // define resources here
    new DockerProvider(this, "default");

    Image dockerImage =
      new Image(this, "nginxImage", ImageConfig.builder().name("nginx:latest").keepLocally(true).build());

    new Container(this, "nginxContainer", ContainerConfig.builder().image(dockerImage.getLatest()).name("tutorial").ports(Collections.singletonList(ContainerPorts.builder().internal(80).external(8000).build())).build());
  }

  public static void main(String[] args) {
    final App app = new App();
    new Main(app, "terraform-cdk-demo");
    app.synth();
  }
}