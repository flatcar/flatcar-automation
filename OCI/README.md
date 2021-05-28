## Creating Flatcar Bare Metal instances on Oracle Cloud

To create Bare Metal images for Flatcar on Oracle Cloud, we need to deploy
an instance of Ubuntu or Oracle Linux and then convert it into Flatcar.

To do that, we first deploy the other OS, run the commands in the
corresponding `modify-{ubuntu|oracle}.sh` script, which downloads and
installs the Flatcar installer and reboots into it.  Then log in to the
Flatcar installer, to do this, you need to make sure that the ignition
config passed includes your key.

This ignition config should be based on the `installer-ignition.json` file
provided here, so that the iSCSI drive is also mounted automatically. This
config needs to be passed as the user-data of the initial instance.  As
neither Ubuntu nor Oracle Linux support ignition, they will ignore this
user-data when they boot.

After logging in to the Flatcar installer, download and install the Flatcar
image by running the commands in the corresponding
`install-flatcar-{amd64|arm64}.sh`

The Flatcar image to use needs to be equal or newer than v2857.0.0, for
both ARM and AMD64, because iSCSI support was added there.

Once the Flatcar image is installed, the machine gets powered off and the
Bare Metal OCI image can be created from the instance. For these instances,
the `running-instance-ignition.json` example file can be used.
