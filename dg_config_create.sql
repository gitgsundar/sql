create configuration 'epsxgp1' primary database is 'epsxgp1' connect identifier is 'epsxgp1';
add database 'epsxgf1' as connect identifier is 'epsxgf1' maintained as physical;
enable configuration;
 


----- SMA 

CREATE CONFIGURATION 'epsmap1' AS
  PRIMARY SITE IS 'epsmap1'
  RESOURCE IS 'epsmap1'
  HOSTNAME IS 'fwpmadprd02'
  INSTANCE NAME IS 'epsmap1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=epsmapcov1.fmr.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=epsmap1)))'
    SITE IS MAINTAINED AS PHYSICAL;

CREATE SITE 'epsmaf1'
  RESOURCE IS 'epsmaf1'
  HOSTNAME IS 'swlk48'
  INSTANCE NAME IS 'epsmaf1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=epsmapwlk1.fmr.com)(Port=1521))(CONNECT_DATA=(SERVICE_NAME=epsmaf1)))'
    SITE IS MAINTAINED AS PHYSICAL;

enable configuration;

----- CM Prod

CREATE CONFIGURATION 'epscmp1' AS
  PRIMARY SITE IS 'epscmp1'
  RESOURCE IS 'epscmp1'
  HOSTNAME IS 'fwpmadprd01'
  INSTANCE NAME IS 'epscmp1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=epscmpcov1.fmr.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=epscmp1)))'
    SITE IS MAINTAINED AS PHYSICAL;

CREATE SITE 'epscmf1'
  RESOURCE IS 'epscmf1'
  HOSTNAME IS 'swlk48'
  INSTANCE NAME IS 'epscmf1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=epscmpwlk1.fmr.com)(Port=1521))(CONNECT_DATA=(SERVICE_NAME=epscmf1)))'
    SITE IS MAINTAINED AS PHYSICAL;

enable configuration;


----- CM Preflight

CREATE CONFIGURATION 'epscpp1' AS
  PRIMARY SITE IS 'epscpp1'
  RESOURCE IS 'epscpp1'
  HOSTNAME IS 'fwpmadprd01'
  INSTANCE NAME IS 'epscpp1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=epscppcov1.fmr.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=epscpp1)))'
    SITE IS MAINTAINED AS PHYSICAL;

CREATE SITE 'epscpf1'
  RESOURCE IS 'epscpf1'
  HOSTNAME IS 'swlk48'
  INSTANCE NAME IS 'epscpf1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=epscppwlk1.fmr.com)(Port=1521))(CONNECT_DATA=(SERVICE_NAME=epscpf1)))'
    SITE IS MAINTAINED AS PHYSICAL;

enable configuration;

----- IDB Prod

CREATE CONFIGURATION 'epidbp1' AS
  PRIMARY SITE IS 'epidbp1'
  RESOURCE IS 'epidbp1'
  HOSTNAME IS 'fwpmadprd01'
  INSTANCE NAME IS 'epidbp1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=epidbpcov1.fmr.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=epidbp1)))'
    SITE IS MAINTAINED AS PHYSICAL;

CREATE SITE 'epidbf1'
  RESOURCE IS 'epidbf1'
  HOSTNAME IS 'swlk48'
  INSTANCE NAME IS 'epidbf1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=epidbpwlk1.fmr.com)(Port=1521))(CONNECT_DATA=(SERVICE_NAME=epidbf1)))'
    SITE IS MAINTAINED AS PHYSICAL;

enable configuration;


----- IDB Preflight

CREATE CONFIGURATION 'epidpp1' AS
  PRIMARY SITE IS 'epidpp1'
  RESOURCE IS 'epidpp1'
  HOSTNAME IS 'fwpmadprd01'
  INSTANCE NAME IS 'epidpp1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=epidppcov1.fmr.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=epidpp1)))'
    SITE IS MAINTAINED AS PHYSICAL;

CREATE SITE 'epidpf1'
  RESOURCE IS 'epidpf1'
  HOSTNAME IS 'swlk48'
  INSTANCE NAME IS 'epidpf1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=epidppwlk1.fmr.com)(Port=1521))(CONNECT_DATA=(SERVICE_NAME=epidpf1)))'
    SITE IS MAINTAINED AS PHYSICAL;

enable configuration;


----- eAccess

CREATE CONFIGURATION 'epeacp1' AS
  PRIMARY SITE IS 'epeacp1'
  RESOURCE IS 'epeacp1'
  HOSTNAME IS 'fwpmadprd01'
  INSTANCE NAME IS 'epeacp1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=epeacpcov1.fmr.com)(PORT=1523)))(CONNECT_DATA=(SERVICE_NAME=epeacp1)))'
    SITE IS MAINTAINED AS PHYSICAL;

CREATE SITE 'epeacf1'
  RESOURCE IS 'epeacf1'
  HOSTNAME IS 'swlk48'
  INSTANCE NAME IS 'epeacf1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=epseapwlk1.fmr.com)(Port=1521))(CONNECT_DATA=(SERVICE_NAME=epeacf1)))'
    SITE IS MAINTAINED AS PHYSICAL;

enable configuration;

----- Checkmate

CREATE CONFIGURATION 'Checkmate' AS
  PRIMARY SITE IS 'cmatep1'
  RESOURCE IS 'cmatep1'
  HOSTNAME IS 'scov39'
  INSTANCE NAME IS 'cmatep1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=epchkpcov1.fmr.com)(Port=1521))(CONNECT_DATA=(SERVICE_NAME=cmatep1)))'
    SITE IS MAINTAINED AS PHYSICAL;

CREATE SITE 'epchkf1'
  RESOURCE IS 'epchkf1'
  HOSTNAME IS 'swlk22'
  INSTANCE NAME IS 'epchkf1'
  SERVICE NAME IS '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=epchkpwlk1.fmr.com)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=epchkf1)))'
    SITE IS MAINTAINED AS PHYSICAL;

enable configuration;
