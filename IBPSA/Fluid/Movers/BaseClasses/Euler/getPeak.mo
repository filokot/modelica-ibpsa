within IBPSA.Fluid.Movers.BaseClasses.Euler;
function getPeak
  "Find peak condition from power characteristics"
  extends Modelica.Icons.Function;
  input IBPSA.Fluid.Movers.BaseClasses.Characteristics.flowParameters
    pressure "Pressure vs. flow rate";
  input BaseClasses.Characteristics.powerParameters
    power "Power vs. flow rate";
  output IBPSA.Fluid.Movers.BaseClasses.Euler.peak
    peak "Operation point at maximum efficiency";

protected
  parameter Integer n = size(pressure.V_flow, 1) "Number of data points";
  parameter Modelica.Units.SI.VolumeFlowRate V_flow_hal=
    if max(pressure.V_flow) < 1E-6
      then 0
    else (pressure.V_flow[n]
                -(pressure.V_flow[n] - pressure.V_flow[n - 1])
                /(pressure.dp[n] - pressure.dp[n - 1])
                * pressure.dp[n])/2
    "Half of max flow, max flow is where dp=0";
  parameter Modelica.Units.SI.PressureDifference dpHalFlo=
    if max(pressure.V_flow) < 1E-6
      then 0
    else IBPSA.Utilities.Math.Functions.smoothInterpolation(
               x=peak.V_flow,
               xSup=pressure.V_flow,
               ySup=pressure.dp,
               ensureMonotonicity=true)
    "Pressure rise at half flow";

  Real eta[n] "Efficiency series";
  Boolean etaLes "Efficiency series has less than four points";
  Boolean etaMon "Efficiency series is monotonic";

  // A b = y
  Real A[n,5] "Design matrix";
  Real b[5] "Parameter vector";
  Real r[3,2] "Roots";
algorithm

  if max(pressure.V_flow) < 1E-6 and
     max(pressure.dp)     < 1E-6 then
    // If there is no pressure curve, no estimation can be made
    peak.V_flow:=0;
    peak.dp:=0;
    peak.eta:=0.7;

  elseif max(power.P) < 1E-6 then
    // If a pressure curve is available, but no power curve,
    //   peak.V_flow = V_flow_max / 2,
    //   peak.dp = dp(V_flow = V_flow_max / 2)
    peak.V_flow:=V_flow_hal;
    peak.dp:=dpHalFlo;
    peak.eta:=0.7;

  else
    // Both a pressure curve and a power curve are available.
    eta:=pressure.V_flow.*pressure.dp./power.P;
    etaLes:=n<4;
    etaMon:=IBPSA.Utilities.Math.Functions.isMonotonic(
      x=eta,
      strict=false);

    if etaLes or etaMon then
    // If less than four data points are provided or the efficiency curve is
    //   monotonic, use the one of two which has the higher efficiency:
    //   1. the interpolated point at half of max flow;
    //   2. the available point with the highest efficiency.
      peak.eta:=IBPSA.Utilities.Math.Functions.smoothInterpolation(
               x=V_flow_hal,
               xSup=pressure.V_flow,
               ySup=eta,
               ensureMonotonicity=
                 IBPSA.Utilities.Math.Functions.isMonotonic(eta, strict=false));
      if peak.eta>max(eta) then
             peak.V_flow:=V_flow_hal;
             peak.dp:=dpHalFlo;
      else
        peak.eta:=max(eta);
        for i in 1:n loop
          if abs(eta[i]-peak.eta)<1E-6 then
            peak.V_flow:=pressure.V_flow[i];
            peak.dp:=pressure.dp[i];
          end if;
        end for;
      end if;
    else

      // Constructs the matrix equation A b = y for quartic regression, where
      //   A is a 5-by-n design matrix,
      //   b is a parameter vector with length 5,
      //   and y = eta is the response vector with length n.
      A[:,1]:=ones(n); // Avoids 0^0
      for i in 2:5 loop
        A[:,i]:=pressure.V_flow[:].^(i-1);
      end for;
      b:=Modelica.Math.Matrices.leastSquares(A,eta);

      // Solve the derivative for the max eta and corresponding V_flow.
      // This assumes that there will only be one real solution
      //   and it falls within the range of V_flow[:].
      r:=Modelica.Math.Polynomials.roots({b[5]*4,b[4]*3,b[3]*2,b[2]});
      for i in 1:3 loop
        if abs(r[i,2])<=1E-6 and
          r[i,1]>pressure.V_flow[1] and r[i,1]<pressure.V_flow[n] then
          peak.V_flow:=r[i,1];
        end if;
      end for;
      peak.eta:=IBPSA.Utilities.Math.Functions.smoothInterpolation(
        x=peak.V_flow,
        xSup=pressure.V_flow,
        ySup=eta,
        ensureMonotonicity=false);
      peak.dp:=IBPSA.Utilities.Math.Functions.smoothInterpolation(
        x=peak.V_flow,
        xSup=pressure.V_flow,
        ySup=pressure.dp,
        ensureMonotonicity=false);
    end if;
  end if;

  annotation(smoothOrder=1,
              Documentation(info="<html>
<p>
This function finds or estimates the peak point
<i>(V&#775;,&Delta;p,&eta;)|&eta;=&eta;<sub>max</sub></i>
from the input power curve <i>P(V&#775;)</i>
and pressure curve <i>&Delta;p(V&#775;)</i>
which may or may not contain non-zero values.
The results are output as an instance of
<a href=\"modelica://IBPSA.Fluid.Movers.BaseClasses.Euler.peak\">
IBPSA.Fluid.Movers.BaseClasses.Euler.peak</a>.
There are the following branches of computation based on information provided
to the function:
</p>
<ul>
<li>
If <i>&Delta;p(V&#775;)</i> is unavailable, the function simply outputs
<i>(0,0,0.7)</i>.
</li>
<li>
If <i>&Delta;p(V&#775;)</i> is provided but <i>P(V&#775;)</i> is unavailable,
the function provides an estimation of the peak point at half of max flow rate
<i>(V&#775;<sub>max</sub> &frasl; 2,
&Delta;p(V&#775;=V&#775;<sub>max</sub> &frasl; 2),
0.7)</i>.
</li>
<li>
If both <i>&Delta;p(V&#775;)</i> and <i>P(V&#775;)</i> are available,
the function first computes
<i>&eta;(V&#775;)=V&#775;&nbsp;&Delta;p &frasl; P</i>.
<ul>
<li>
If <i>&eta;(V&#775;)</i> has less than four data points or is monotonic,
use one of the two which ever produces a higher <i>&eta;</i>:
<ul>
<li>
The interpolated point at half of max flow rate
<i>(V&#775;<sub>max</sub> &frasl; 2,
&Delta;p(V&#775;=V&#775;<sub>max</sub> &frasl; 2),
&eta;(V&#775;=V&#775;<sub>max</sub> &frasl; 2))</i>
</li>
<li>
The available point with the highest computed efficiency.
</li>
</ul>
</li>
<li>
Otherwise, the function runs a quartic regression on <i>&eta;(V&#775;)</i>
then solves its derivative to find an extremum.
It assumes that there is only one extremum on the open interval
<i>(0,V&#775;<sub>max</sub>)</i>.
</li>
</ul>
</li>
</ul>
</html>",
revisions="<html>
<ul>
<li>
August 18, 2022, by Hongxiang Fu:<br/>
First implementation. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2668\">#2668</a>.
</li>
</ul>
</html>"));
end getPeak;
