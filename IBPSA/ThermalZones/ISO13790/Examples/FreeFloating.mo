within IBPSA.ThermalZones.ISO13790.Examples;
model FreeFloating "Illustrates the use of the 5R1C thermal zone in free-floating conditions"
  extends Modelica.Icons.Example;

  IBPSA.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        Modelica.Utilities.Files.loadResource("modelica://IBPSA/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos")) "weather data"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
  Zone5R1C.Zone zon5R1C(
    airRat=0.5,
    AWin={0,0,3,0},
    UWin=1.8,
    AWal={12,12,9,12},
    ARoo=16,
    UWal=1.3,
    URoo=1.3,
    UFlo=1,
    AFlo=16,
    VRoo=16*3,
    facMas=2.5,
    redeclare IBPSA.ThermalZones.ISO13790.Data.Light buiMas,
    nOrientations=4,
    surTil={1.5707963267949,1.5707963267949,1.5707963267949,1.5707963267949},
    surAzi={3.1415926535898,-1.5707963267949,0,1.5707963267949},
    gFac=0.5) "Thermal zone"
    annotation (Placement(transformation(extent={{26,-12},{54,16}})));
  Modelica.Blocks.Sources.Constant intGains(k=10) "internal heat gains in Watt"
    annotation (Placement(transformation(extent={{-80,-40},{-60,-20}})));
equation
  connect(zon5R1C.weaBus, weaDat.weaBus) annotation (Line(
      points={{30.6,13},{-50,13},{-50,10},{-60,10}},
      color={255,204,51},
      thickness=0.5));
  connect(zon5R1C.intSenGai, intGains.y)
    annotation (Line(points={{24,-10},{-48,-10},{-48,-30},{-59,-30}}, color={0,0,127}));
  annotation (experiment(Tolerance=1e-6, StopTime=3.1536e+007),
  __Dymola_Commands(file=
  "modelica://IBPSA/Resources/Scripts/Dymola/ThermalZones/ISO13790/Examples/FreeFloating.mos"
        "Simulate and plot"),
  Documentation(info="<html>
<p>
This model illustrates the use of <a href=\"modelica://IBPSA.ThermalZones.ISO13790.Zone5R1C.Zone\">
IBPSA.ThermalZones.ISO13790.Zone5R1C.Zone</a> in a free-floating case 
(i.e. no heating or cooling)
</p>
</html>",
revisions="<html>
<ul>
<li>
Mar 16, 2022, by Alessandro Maccarini:<br/>
First implementation.
</li>
</ul>
</html>"));
end FreeFloating;
