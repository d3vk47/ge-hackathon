# Ensure the USER environment variable is set
if [ -z "$USER" ]; then
  echo "Error: The USER environment variable is not set."
  exit 1
fi

echo "********************************************************************************"
echo "*** Your database will be called:                                            ***"
echo "***   fintrac_prod_$USER"
echo "********************************************************************************"
