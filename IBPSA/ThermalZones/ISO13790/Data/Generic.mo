within IBPSA.ThermalZones.ISO13790.Data;
record Generic "Generic data record building mass"
   extends Modelica.Icons.Record;

   parameter Real heaC
    "heat capacity"
    annotation (Dialog(group="Heat mass"));

  annotation (defaultComponentName="mas",
Documentation(revisions="<html>
<ul>
<li>
May 20, 2016, by Alessandro Maccarini:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
Performance data for a generic active beam.
</p>
</html>"));
end Generic;
