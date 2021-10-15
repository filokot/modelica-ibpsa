within IBPSA.Fluid.Movers.Validation;
model PowerExact
  "Power calculation comparison among three mover types, using exact power computation for m_flow and dp"
  extends PowerSimplified(
    pump_dp(per=per),
    pump_m_flow(per=per));
  annotation (
    experiment(Tolerance=1e-6, StopTime=200),
    __Dymola_Commands(file=
          "modelica://IBPSA/Resources/Scripts/Dymola/Fluid/Movers/Validation/PowerExact.mos"
        "Simulate and plot"),
        Documentation(
info="<html>
<p>
This example is identical to
<a href=\"modelica://IBPSA.Fluid.Movers.Validation.PowerSimplified\">
IBPSA.Fluid.Movers.Validation.PowerSimplified</a>, except that the
performance data for the flow controlled pumps
<code>pump_dp</code> and <code>pump_m_flow</code> contain
the pressure curves and efficiency curves.
The plot below shows that this leads to a computation of the power consumption
that is identical to the one from the speed controlled pump <code>pump_Nrpm</code>.
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://IBPSA/Resources/Images/Fluid/Movers/Validation/PowerExact.png\"/>
</p>
</html>",
revisions="<html>
<ul>
<li>
October 15, 2021, by Hongxiang Fu:<br/>
Fixed the image in the documentation which was cut off 
at the <i>y</i>-axis. This is for 
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1533\">ibpsa#1533</a>.
</li>
<li>
March 2, 2016, by Filip Jorissen:<br/>
First implementation for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/417\">#417</a>.
</li>
</ul>
</html>"));
end PowerExact;
