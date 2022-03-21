within IBPSA.ThermalZones.ISO13790.Validation.BESTEST;
model Case900FF "Test with heavy-weight construction and free floating temperature"
  extends Modelica.Icons.Example;
  BoundaryConditions.WeatherData.ReaderTMY3       weaDat(filNam=
        Modelica.Utilities.Files.loadResource(
        "modelica://IBPSA/Resources/weatherdata/DRYCOLD.mos"))
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Zone5R1C.Zone zon5R1C(
    nVe=0.5,
    Awin={0,0,12,0},
    Uwin=2.984,
    Awal={21.6,16.2,9.6,16.2},
    Aroo=48,
    Uwal=0.51,
    Uroo=0.32,
    Af=48,
    Vroo=129.6,
    f_ms=2.7,
    redeclare IBPSA.ThermalZones.ISO13790.Data.BESTEST900 buiMas,
    winFrame=0.01,
    gFactor=0.789)
    annotation (Placement(transformation(extent={{-14,-14},{14,14}})));
  Modelica.Blocks.Sources.Constant intGains(k=200)
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
equation
  connect(weaDat.weaBus,zon5R1C. weaBus) annotation (Line(
      points={{-60,70},{-38,70},{-38,11},{-9.4,11}},
      color={255,204,51},
      thickness=0.5));
  connect(intGains.y,zon5R1C. intGains) annotation (Line(points={{-39,-30},{-22,
          -30},{-22,-12},{-16,-12}}, color={0,0,127}));
annotation(experiment(
      StopTime=31536000,
      Interval=3600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Dassl"),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/ThermalZones/Detailed/Validation/BESTEST/Cases6xx/Case600FF.mos"
        "Simulate and plot"), Documentation(info="<html>
<p>
This model is used for the test case 900FF of the BESTEST validation suite.
Case 900FF is a heavy-weight building.
The room temperature is free floating.
</p>
</html>", revisions="<html><ul>
<li>
Mar 16, 2022, by Alessandro Maccarini:<br/>
First implementation.
</li>
</ul></html>"));
end Case900FF;
