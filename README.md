## Dependencies

* JQ
* OpenStack SDK
* Packer

## Usage

**source setup/lims2_opens_setup.sh**

**lims2-opens**


*A set of commands to build a LIMS2 environment on OpenStack.*


*Version: 0.1*


*Usage:*


*- DB -*

*. lims2-db-create-image: Create a base image for a LIMS2 database server.*

*. lims2-db-launch-instance: Launch a database server accepting connections at port 5432 (PGSQL port).*

*. lims2-db-configure: Create a LIMS2 database on a running database instance.*


*- WebApp -*

*. lims2-webapp-create-image: Create a base image having LIMS2 WebApp specifications.*

*. lims2-webapp-launch-instance: Launch an instance from the LIMS2-spec base image and open port 3000.*

*. lims2-webapp-configure: Configure a LIMS2-spec instance to act as Gitlab runner or a HTGT3 server.*


