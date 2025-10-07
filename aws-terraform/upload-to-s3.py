import boto3
import sys
import os

# Configuration - update with your student ID
WEBSITE_BUCKET_NAME = 'tasktracker-YOUR_STUDENT_ID-assets'  # We'll update this
S3_CLIENT = boto3.client('s3')

def create_bucket_if_not_exists():
    """Create S3 bucket if it doesn't exist (like your lab 8)"""
    try:
        S3_CLIENT.head_bucket(Bucket=WEBSITE_BUCKET_NAME)
        print(f"✅ Bucket {WEBSITE_BUCKET_NAME} already exists")
    except:
        try:
            S3_CLIENT.create_bucket(Bucket=WEBSITE_BUCKET_NAME)
            print(f"✅ Created bucket {WEBSITE_BUCKET_NAME}")
        except Exception as e:
            print(f"❌ Error creating bucket: {e}")
            sys.exit(1)

def upload_file(local_file, s3_key, content_type='text/html'):
    """Upload a single file to S3 (same pattern as your put_object.py)"""
    try:
        S3_CLIENT.upload_file(
            Filename=local_file,
            Bucket=WEBSITE_BUCKET_NAME,
            Key=s3_key,
            ExtraArgs={'ContentType': content_type}
        )
        print(f"✅ Uploaded {local_file} to s3://{WEBSITE_BUCKET_NAME}/{s3_key}")
        return True
    except Exception as e:
        print(f"❌ Error uploading {local_file}: {e}")
        return False

def main():
    """Upload all task tracker files"""
    print("🚀 Uploading Task Tracker files to S3...")
    
    # Create bucket
    create_bucket_if_not_exists()
    
    # Upload application files from parent directory
    files_to_upload = [
        ('../www/index.html', 'www/index.html', 'text/html'),
        ('../www/api.php', 'www/api.php', 'application/x-httpd-php'),
        ('../www/api-info.html', 'www/api-info.html', 'text/html'),
        ('../setup-database.sql', 'database/setup-database.sql', 'text/plain')
    ]
    
    success_count = 0
    for local_file, s3_key, content_type in files_to_upload:
        if os.path.exists(local_file):
            if upload_file(local_file, s3_key, content_type):
                success_count += 1
        else:
            print(f"⚠️  File {local_file} not found, skipping...")
    
    print(f"\n✅ Upload complete: {success_count}/{len(files_to_upload)} files uploaded")
    print(f"📦 Bucket: {WEBSITE_BUCKET_NAME}")

if __name__ == "__main__":
    main()