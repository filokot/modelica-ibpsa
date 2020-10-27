within IBPSA.Media;
package Steam
  "Package with model for region 2 (steam) water according to IF97 standard"
  extends Modelica.Media.Interfaces.PartialCondensingGases(
     mediumName="steam",
     final substanceNames={"water"},
     singleState = true,
     reducedX = true,
     fixedX = true,
     fluidConstants={Modelica.Media.IdealGases.Common.FluidData.H2O},
     reference_T=273.15,
     reference_p=101325,
     reference_X={1},
     AbsolutePressure(start=p_default),
     Temperature(start=T_default),
     SpecificEnthalpy(start=1.0e5, nominal=5.0e5),
     Density(start=150, nominal=500),
     T_default=Modelica.SIunits.Conversions.from_degC(100));
  extends Modelica.Icons.Package;

  redeclare record extends ThermodynamicState
    "Thermodynamic state variables"
        AbsolutePressure p(start=p_default) "Absolute pressure of medium";
        Temperature T(start=T_default) "Temperature of medium";
    //    MassFraction[nX] X(start=reference_X);
    //      "Mass fractions (= (component mass)/total mass  m_i/m)";
  end ThermodynamicState;
  constant Integer region = 2 "Region of IF97, if known, zero otherwise";
  constant Integer phase = 1 "1 for one-phase";

  redeclare replaceable model extends BaseProperties(
    preferredMediumStates = true,
    final standardOrderComponents=true)
    "Base properties (p, d, T, h, u, R, MM, sat) of water"
    //    X(each stateSelect=if preferredMediumStates then StateSelect.prefer else StateSelect.default),
  equation
    // Temperature and pressure values must be within acceptable max & min bounds
    // Assert statements
    MM = steam.MM;
    h = specificEnthalpy(state);
    d = density(state);
    //d = p/(R*T);
    u = h - p/d;
    R = steam.R;
    state.p = p;
    state.T = T;
    //    Xi=fill(0, 0);
    //   X={1};
    state.X = reference_X;
    //X = reference_X;
  end BaseProperties;

redeclare replaceable function extends density
  "Returns density"
algorithm
  d := rho_pT(state.p,state.T);
  annotation (Inline=true);
end density;
/*  redeclare replaceable function extends density
  "Returns density"
  protected 
  Real a[:] = {2.752,2.938,-0.8873,-0.8445,0.2132};
  AbsolutePressure pMean =  8.766717603911981e+05;
  Temperature TMean =  7.104788508557040e+02;
  Real pSD = 8.540705946819051e+05;
  Real TSD = 1.976242680354902e+02;
  AbsolutePressure pHat;
  Temperature THat;
algorithm 
  pHat := (state.p - pMean)/pSD;
  THat := (state.T - TMean)/TSD;
  d := a[1] + a[2]*pHat + a[3]*THat + a[4]*pHat*THat + a[5]*THat^2;
  annotation (Inline=true,smoothOrder=2);
end density;
redeclare replaceable function extends density
  "Returns density"
  protected 
  Real a[:] = {2.702,2.653,-0.7555,0.02029,-0.7485,0.2043,-0.0521,0.2587,
    -0.1007,0.06978,-0.1735,0.0566,-0.02713,0.06016,-0.01156};
  AbsolutePressure pMean =  8.766717603911981e+05;
  Temperature TMean =  7.104788508557040e+02;
  Real pSD = 8.540705946819051e+05;
  Real TSD = 1.976242680354902e+02;
  AbsolutePressure pHat;
  Temperature THat;
algorithm 
   // function of state
   //d := state.p/(steam.R*state.T);
  pHat :=(state.p - pMean)/pSD;
  THat :=(state.T - TMean)/TSD;
  d := a[1] + a[2]*pHat + a[3]*THat + a[4]*pHat^2 + a[5]*pHat*THat +
    a[6]*THat^2 + a[7]*pHat^2*THat + a[8]*pHat*THat^2 + a[9]*THat^3 +
    a[10]*pHat^2*THat^2 + a[11]*pHat*THat^3 + a[12]*THat^4 +
    a[13]*pHat^2*THat^3 + a[14]*pHat*THat^4 + a[15]*THat^5;
  annotation (Inline=true);
end density;
*/

redeclare function extends dynamicViscosity
    "Return dynamic viscosity"
algorithm
    eta := Modelica.Media.Water.IF97_Utilities.dynamicViscosity(
          d=density(state),
          T=state.T,
          p=state.p);
    annotation (Inline=true);
end dynamicViscosity;

redeclare replaceable function extends enthalpyOfVaporization
  "Return vaporization enthalpy of condensing fluid"
  //    input Temperature T "Temperature";
  //    output SpecificEnthalpy r0 "Vaporization enthalpy";
algorithm
  r0 := Modelica.Media.Water.IF97_Utilities.BaseIF97.Regions.hv_p(
      saturationPressure(T)) -
    Modelica.Media.Water.IF97_Utilities.BaseIF97.Regions.hl_p(
      saturationPressure(T));
annotation (Inline=true);
end enthalpyOfVaporization;

redeclare replaceable function extends specificEnthalpy
  "Returns specific enthalpy"
  protected
  Real a[:] = {3.354e+06,-1.661e+04,4.276e+05};
  AbsolutePressure pMean =  8.766717603911981e+05;
  Temperature TMean =  7.104788508557040e+02;
  Real pSD = 8.540705946819051e+05;
  Real TSD = 1.976242680354902e+02;
  AbsolutePressure pHat;
  Temperature THat;
algorithm
  pHat := (state.p - pMean)/pSD;
  THat := (state.T - TMean)/TSD;
  h := a[1] + a[2]*pHat + a[3]*THat;
annotation (Inline=true,smoothOrder=2);
end specificEnthalpy;

redeclare replaceable function extends molarMass
  "Return the molar mass of the medium"
algorithm
  MM := steam.MM;
end molarMass;

redeclare function extends pressure
  "Return pressure"
algorithm
  p := state.p;
end pressure;

replaceable function pressure_dT
  "Return pressure from d and T, inverse function of d(p,T)"
  input Density d "Density";
  input Temperature T "Temperature";
  output AbsolutePressure p "Absolute Pressure";
  protected
  Real a[:] = {2.752,2.938,-0.8873,-0.8445,0.2132};
  AbsolutePressure pMean =  8.766717603911981e+05;
  Temperature TMean =  7.104788508557040e+02;
  Real pSD = 8.540705946819051e+05;
  Real TSD = 1.976242680354902e+02;
  Temperature THat;
algorithm
  THat := (T - TMean)/TSD;
  p := pSD/(a[2]+a[4]*THat)*(-a[1]+d-THat*(a[3]+a[5]*THat))+pMean;
annotation (Inline=true,smoothOrder=1);
end pressure_dT;

 redeclare replaceable function extends saturationPressure
  "Return saturation pressure of condensing fluid"
  //    input Temperature Tsat "Saturation temperature";
  //    output AbsolutePressure psat "Saturation pressure";
 algorithm
   psat := Modelica.Media.Water.IF97_Utilities.BaseIF97.Basic.psat(Tsat);

 annotation (Inline=true);
 end saturationPressure;

replaceable function saturationTemperature
    "Return saturation temperature"
  input AbsolutePressure psat "Saturation pressure";
  output Temperature Tsat "Saturation temperature";
algorithm
    Tsat := Modelica.Media.Water.IF97_Utilities.BaseIF97.Basic.tsat(psat);
    annotation (Inline=true);
end saturationTemperature;
/*replaceable function saturationTemperature
  "Return saturation temperature from a given pressure"
  extends Modelica.Icons.Function;
  input AbsolutePressure p "Pressure";
  output Temperature T   "Saturation temperature";
  protected 
  Real a[:] = {2.2830066E+02,1.1893913E+00,5.2484699E-01,1.2416857E-01,
    -1.3714779E-02,5.5702047E-04}
    "Coefficients";
  Real logP = log(p);
algorithm 
  T := a[1] + a[2]*logP + a[3]*logP^2 + a[4]*logP^3 +
    a[5]*logP^4 + a[6]*logP^5
  "Saturation temperature";
annotation (
  smoothOrder=2,
  Documentation(info="<html>
  <p>
  Saturation temperature is computed from pressure. This relation is
  valid in the region of <i>273.16</i> to <i>647.096</i> K (<i>613.3</i> to <i>22,049,100</i> Pa).
  </p>
  <p>
  The function has the following form:
  </p>
  <p align=\"center\" style=\"font-style:italic;\">
  T = a<sub>1</sub> + a<sub>2</sub> ln(p) + a<sub>3</sub> ln(p)<sup>2</sup> +
  a<sub>4</sub> ln(p)<sup>3</sup> + a<sub>5</sub> ln(p)<sup>4</sup> + a<sub>6</sub> ln(p)<sup>5</sup>
  </p>
  <p>
  where temperature <i>T</i> is in units Kelvin, pressure <i>p</i> is in units Pa, and <i>a<sub>1</sub></i>
  through <i>a<sub>6</sub></i> are regression coefficients.
  </p>
  </html>", revisions="<html>
  <ul>
  <li>
  March 6, 2020, by Kathryn Hinkelman:<br/>
  First implementation.
  </li>
  </ul>
  </html>"));
end saturationTemperature;*/

redeclare function extends specificEntropy
  "Return specific entropy"
  protected
  Real a[:] = {7801,-445.2,594.7};
  AbsolutePressure pMean =  8.766717603911981e+05;
  Temperature TMean =  7.104788508557040e+02;
  Real pSD = 8.540705946819051e+05;
  Real TSD = 1.976242680354902e+02;
  AbsolutePressure pHat;
  Temperature THat;
algorithm
  pHat := (state.p - pMean)/pSD;
  THat := (state.T - TMean)/TSD;
  s := a[1] + a[2]*pHat + a[3]*THat;
annotation (Inline=true,smoothOrder=1);
end specificEntropy;

redeclare replaceable function extends specificInternalEnergy
  "Return specific internal energy"
algorithm
  u := specificEnthalpy(state) - state.p/density(state);
  annotation (Inline=true);
end specificInternalEnergy;

redeclare replaceable function extends specificHeatCapacityCp
  "Specific heat capacity at constant pressure"
algorithm
  cp := cp_pT(state.p,state.T);
  annotation (Inline=true);
end specificHeatCapacityCp;

redeclare replaceable function extends specificHeatCapacityCv
  "Specific heat capacity at constant volume"
algorithm
  cv := cv_pT(state.p,state.T);
  annotation (Inline=true);
end specificHeatCapacityCv;

redeclare replaceable function extends specificGibbsEnergy
   "Specific Gibbs energy"
algorithm
  g := specificEnthalpy(state) - state.T*specificEntropy(state);
  annotation (Inline=true);
end specificGibbsEnergy;

redeclare replaceable function extends specificHelmholtzEnergy
   "Specific Helmholtz energy"
algorithm
  f := specificEnthalpy(state) - steam.R*state.T - state.T*specificEntropy(state);
  annotation (Inline=true);
end specificHelmholtzEnergy;

redeclare function extends setState_dTX
    "Return the thermodynamic state as function of d, T and composition X or Xi"
algorithm
  state := ThermodynamicState(p=pressure_dT(d,T), T=T, X={1});
annotation (Inline=true,smoothOrder=2);
end setState_dTX;

redeclare function extends setState_pTX
    "Return the thermodynamic state as function of p, T and composition X or Xi"
algorithm
  state := ThermodynamicState(p=p, T=T, X={1});
annotation (Inline=true,smoothOrder=2);
end setState_pTX;

redeclare function extends setState_phX
    "Return the thermodynamic state as function of p, h and composition X or Xi"
algorithm
  state := ThermodynamicState(p=p, T=temperature_ph(p,h), X={1});
annotation (Inline=true,smoothOrder=2);
end setState_phX;

redeclare function extends setState_psX
    "Return the thermodynamic state as function of p, s and composition X or Xi"
algorithm
  state := ThermodynamicState(p=p, T=temperature_ps(p,s), X={1});
annotation (Inline=true,smoothOrder=2);
end setState_psX;

redeclare function extends temperature
    "Return temperature"
algorithm
  T := state.T;
end temperature;

replaceable function temperature_ph
  "Return temperature from p and h, inverse function of h(p,T)"
  input AbsolutePressure p "Absolute Pressure";
  input SpecificEnthalpy h "Specific Enthalpy";
  output Temperature T "Temperature";
  protected
  Real a[:] = {3.354e+06,-1.661e+04,4.276e+05} "Coefficients from forward function h(p,T)";
  Real b[:] = {-a[1]*TSD/a[3]+TMean, -a[2]*TSD/a[3], TSD/a[3]};
  AbsolutePressure pMean =  8.766717603911981e+05;
  Temperature TMean =  7.104788508557040e+02;
  Real pSD = 8.540705946819051e+05;
  Real TSD = 1.976242680354902e+02;
  AbsolutePressure pHat;
algorithm
  pHat := (p - pMean)/pSD;
  T := b[1] + b[2]*pHat + b[3]*h;
annotation (Inline=true,smoothOrder=1);
end temperature_ph;

replaceable function temperature_ps
  "Return temperature from p and s, inverse function of s(p,T)"
  input AbsolutePressure p "Absolute Pressure";
  input SpecificEntropy s "Specific Entropy";
  output Temperature T "Temperature";
  protected
  Real a[:] = {7801,-445.2,594.7} "Coefficients from forward function s(p,T)";
  Real b[:] = {-a[1]*TSD/a[3]+TMean, -a[2]*TSD/a[3], TSD/a[3]};
  AbsolutePressure pMean =  8.766717603911981e+05;
  Temperature TMean =  7.104788508557040e+02;
  Real pSD = 8.540705946819051e+05;
  Real TSD = 1.976242680354902e+02;
  AbsolutePressure pHat;
algorithm
  pHat := (p - pMean)/pSD;
  T := b[1] + b[2]*pHat + b[3]*s;
annotation (Inline=true,smoothOrder=1);
end temperature_ps;

redeclare replaceable function extends thermalConductivity
  "Return thermal conductivity"
algorithm
  lambda := Modelica.Media.Water.IF97_Utilities.thermalConductivity(
        density(state),
        state.T,
        state.p);
  annotation (Inline=true);
end thermalConductivity;

redeclare function extends density_derh_p
  "Density derivative by specific enthalpy"
algorithm
  ddhp := Modelica.Media.Water.IF97_Utilities.ddhp(
        state.p,
        specificEnthalpy(state),
        phase,
        region);
  annotation (Inline=true);
end density_derh_p;

redeclare function extends density_derp_h
  "Density derivative by pressure"
algorithm
  ddph := Modelica.Media.Water.IF97_Utilities.ddph(
        state.p,
        specificEnthalpy(state),
        phase,
        region);
  annotation (Inline=true);
end density_derp_h;

redeclare replaceable function extends isentropicExponent
  "Return isentropic exponent"
algorithm
  gamma := Modelica.Media.Water.IF97_Utilities.isentropicExponent_pT(
        state.p,
        state.T,
        region);
  annotation (Inline=true);
end isentropicExponent;

redeclare replaceable function extends isothermalCompressibility
  "Isothermal compressibility of water"
algorithm
  kappa := Modelica.Media.Water.IF97_Utilities.kappa_pT(
        state.p,
        state.T,
        region);
  annotation (Inline=true);
end isothermalCompressibility;

redeclare replaceable function extends isobaricExpansionCoefficient
  "Isobaric expansion coefficient of water"
algorithm
  beta := Modelica.Media.Water.IF97_Utilities.beta_pT(
        state.p,
        state.T,
        region);
end isobaricExpansionCoefficient;

redeclare replaceable function extends isentropicEnthalpy
  "Compute h(s,p)"
algorithm
  h_is := Modelica.Media.Water.IF97_Utilities.isentropicEnthalpy(
        p_downstream,
        specificEntropy(refState),
        0);
  annotation (Inline=true);
end isentropicEnthalpy;
protected

record GasProperties
  "Coefficient data record for properties of perfect gases"
  extends Modelica.Icons.Record;
  Modelica.SIunits.MolarMass MM "Molar mass";
  Modelica.SIunits.SpecificHeatCapacity R "Gas constant";
end GasProperties;
constant GasProperties steam(
  R =    Modelica.Media.IdealGases.Common.SingleGasesData.H2O.R,
  MM =   Modelica.Media.IdealGases.Common.SingleGasesData.H2O.MM)
  "Steam properties";

function rho_pT "Density as function or pressure and temperature"
  extends Modelica.Icons.Function;
  input AbsolutePressure p "Pressure";
  input Temperature T "Temperature";
  output Density rho "Density";
  protected
  Modelica.Media.Common.GibbsDerivs g
    "Dimensionless Gibbs function and derivatives w.r.t. pi and tau";
  SpecificHeatCapacity R "Specific gas constant of water vapor";
algorithm
  R := Modelica.Media.Water.IF97_Utilities.BaseIF97.data.RH2O;
  // Region 2 properties
  g := g2(p, T);
  rho := p/(R*T*g.pi*g.gpi);
  annotation (smoothOrder=2,Inline=true);
end rho_pT;

function cp_pT
  "Specific heat capacity at constant pressure as function of pressure and temperature"
  extends Modelica.Icons.Function;
  input AbsolutePressure p "Pressure";
  input Temperature T "Temperature";
  output SpecificHeatCapacity cp "Specific heat capacity";
  protected
  Modelica.Media.Common.GibbsDerivs g
    "Dimensionless Gibbs function and derivatives w.r.t. pi and tau";
  SpecificHeatCapacity R "Specific gas constant of water vapor";
  Integer error "Error flag for inverse iterations";
algorithm
  R := Modelica.Media.Water.IF97_Utilities.BaseIF97.data.RH2O;
  // Region 2 properties
  g := g2(p, T);
  cp := -R*g.tau*g.tau*g.gtautau;
  annotation (
    smoothOrder=2,
    Inline=true);
end cp_pT;

function cv_pT
  "Specific heat capacity at constant volume as function of pressure and temperature"
  extends Modelica.Icons.Function;
  input AbsolutePressure p "Pressure";
  input Temperature T "Temperature";
  output SpecificHeatCapacity cv "Specific heat capacity";
  protected
  Modelica.Media.Common.GibbsDerivs g
    "Dimensionless Gibbs function and derivatives w.r.t. pi and tau";
  SpecificHeatCapacity R "Specific gas constant of water vapor";
  Integer error "Error flag for inverse iterations";
algorithm
  R := Modelica.Media.Water.IF97_Utilities.BaseIF97.data.RH2O;
  // Region 2 properties
  g := g2(p, T);
  cv := R*(-g.tau*g.tau*g.gtautau + ((g.gpi - g.tau*g.gtaupi)*(g.gpi
     - g.tau*g.gtaupi)/g.gpipi));
  annotation (
    smoothOrder=2,
    Inline=true);
end cv_pT;

function g2 "Gibbs function for region 2: g(p,T)"
  extends Modelica.Media.Water.IF97_Utilities.BaseIF97.Basic.g2;
  annotation(smoothOrder=1, Inline=true);
end g2;
  annotation (Icon(graphics={
      Line(
        points={{50,30},{30,10},{50,-10},{30,-30}},
        color={0,0,0},
        smooth=Smooth.Bezier),
      Line(
        points={{10,30},{-10,10},{10,-10},{-10,-30}},
        color={0,0,0},
        smooth=Smooth.Bezier),
      Line(
        points={{-30,30},{-50,10},{-30,-10},{-50,-30}},
        color={0,0,0},
        smooth=Smooth.Bezier)}));
end Steam;
