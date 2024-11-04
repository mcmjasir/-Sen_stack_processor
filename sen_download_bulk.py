import asf_search as asf
import argparse
from datetime import date, datetime
from getpass import getpass
import sys
from shapely.geometry import box

def search_and_download(wkt_aoi, platform, processing_level, start_date, end_date, flight_direction, download_path, username, password,
                        beamMode):
    """Search and download satellite imagery based on specified parameters."""
    
    # Perform search
    try:
        results = asf.search(
            platform=platform,
            processingLevel=processing_level,
            start=start_date,
            end=end_date,
            intersectsWith=wkt_aoi,
            flightDirection=flight_direction,
            beamMode = 'IW'
        )
        print(f'Total Images Found: {len(results)}')
    except Exception as e:
        print(f"Error during search: {e}")
        sys.exit(1)
    
    # Authenticate session
    try:
        session = asf.ASFSession().auth_with_creds(username, password)
    except Exception as e:
        print(f"Authentication error: {e}")
        sys.exit(1)
    
    # Download images
    if len(results) > 0:
        print(f"Starting download to {download_path}...")
        results.download(path=download_path, session=session, processes=1)
        print("Download completed.")
    else:
        print("No images found for the specified parameters.")

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Search and download Sentinel-1 satellite imagery.")
    parser.add_argument("-b", "--bbox", type=float, nargs=4, metavar=('min_lon', 'min_lat', 'max_lon', 'max_lat'),
                        required=True, help="Bounding box coordinates: min_lon min_lat max_lon max_lat")
    parser.add_argument("--platform", default="SENTINEL1A", help="Satellite platform, default is SENTINEL1A.")
    parser.add_argument("--processing_level", default="SLC", help="Processing level, default is SLC.")
    parser.add_argument("--start_date", required=True, help="Start date (YYYY-MM-DD).")
    parser.add_argument("--end_date", required=True, help="End date (YYYY-MM-DD).")
    parser.add_argument("--flight_direction", default="DESCENDING", help="Flight direction, default is DESCENDING.")
    parser.add_argument("--download_path", required=True, help="Path to save downloaded images.")
    parser.add_argument("--user", required=True, help="Username")
    parser.add_argument("--pass", required=True, help="Password")
    
    args = parser.parse_args()
    
    # Convert date strings to date objects
    try:
        start_date = datetime.strptime(args.start_date, "%Y-%m-%d").date()
        end_date = datetime.strptime(args.end_date, "%Y-%m-%d").date()
    except ValueError:
        print("Invalid date format. Please use YYYY-MM-DD.")
        sys.exit(1)
    print(args.platform)
    # Prompt for username and password
    #username = input("Enter ASF username: ")
    #password = getpass("Enter ASF password: ")
    username = args.user 
    password = args.pass
    # Create WKT polygon from bounding box
    min_lon, min_lat, max_lon, max_lat = args.bbox
    aoi = box(min_lon, min_lat, max_lon, max_lat).wkt
    print(f"AOI WKT Polygon: {aoi}")
    #aoi='POLYGON ((-94.353383 28.825566, -94.353383 30.630284, -96.192208 30.630284, -96.192208 28.825566, -94.353383 28.825566))'
   
    # Call the main function
    search_and_download(
        wkt_aoi=aoi,
        platform=getattr(asf.PLATFORM,args.platform),
        processing_level=[getattr(asf.PRODUCT_TYPE,args.processing_level)],
        start_date=start_date,
        end_date=end_date,
        flight_direction=args.flight_direction,
        download_path=args.download_path,
        username=username,
        password=password,
        beamMode = 'IW',
    )

if __name__ == "__main__":
    main()
