import os
import boto3
from botocore.exceptions import ClientError

def lambda_handler(event: dict, context: object) -> None:
    # Use a variable for regions. Default to Lambda's region if not provided.
    # To scale: set an Env Var in Terraform called 'TARGET_REGIONS' = "us-east-1,us-west-2"
    regions_str = os.environ.get("TARGET_REGIONS", os.environ["AWS_REGION"])
    regions = [r.strip() for r in regions_str.split(",")]
    
    # Identify action from your EventBridge 'switch'
    # Switch 0 = Stop, Switch 1 = Start
    action = "stop" if str(event.get("switch")) == "0" else "start"
    print(f"Starting execution for action: {action.upper()} across regions: {regions}")

    for region in regions:
        print(f"--- Processing Region: {region} ---")
        rds = boto3.client("rds", region_name=region)
        
        # 1. HANDLE STANDARD INSTANCES
        try:
            instances = rds.describe_db_instances()["DBInstances"]
            for db in instances:
                db_id = db["DBInstanceIdentifier"]
                
                # OPTIONAL: Add a check for Tags here if you don't want to stop EVERYTHING
                try:
                    if action == "stop":
                        rds.stop_db_instance(DBInstanceIdentifier=db_id)
                    else:
                        rds.start_db_instance(DBInstanceIdentifier=db_id)
                    print(f"Successfully sent {action} to Instance: {db_id}")
                except ClientError as e:
                    # Ignore if the DB is already in the target state
                    print(f"Skipping Instance {db_id}: {e.response['Error']['Message']}")
        except Exception as e:
            print(f"Error listing instances in {region}: {e}")

        # 2. HANDLE CLUSTERS (Aurora)
        try:
            clusters = rds.describe_db_clusters()["DBClusters"]
            for cluster in clusters:
                cluster_id = cluster["DBClusterIdentifier"]
                try:
                    if action == "stop":
                        rds.stop_db_cluster(DBClusterIdentifier=cluster_id)
                    else:
                        rds.start_db_cluster(DBClusterIdentifier=cluster_id)
                    print(f"Successfully sent {action} to Cluster: {cluster_id}")
                except ClientError as e:
                    print(f"Skipping Cluster {cluster_id}: {e.response['Error']['Message']}")
        except Exception as e:
            print(f"Error listing clusters in {region}: {e}")