import asyncio
import aiohttp

import pandas as pd
from calendar import monthrange

KM_TO_DEGREE = 1 / 111.32
PIXEL_AREA_KM2 = 1  # Each pixel represents 1 square kilometer
T_avg = 1  

async def fetch_density_data(session, params):
    async with session.get("https://gmtds.maplarge.com/ogc/ais:density/wms", params=params) as response:
        return await response.json()

async def get_density_data_for_day(bbox, year, month, behavior, day):
    min_lat, min_lon, max_lat, max_lon = map(float, bbox.split(','))
    lat_diff = max_lat - min_lat
    lon_diff = max_lon - min_lon

    num_pixels_height = int(lat_diff / KM_TO_DEGREE)
    num_pixels_width = int(lon_diff / KM_TO_DEGREE)

    output_data = []

    time = f"{year}-{month:02d}-{day:02d}T00:00:00Z"

    async with aiohttp.ClientSession() as session:
        tasks = []
        for row in range(num_pixels_height):
            for col in range(num_pixels_width):
                pixel_min_lat = min_lat + row * KM_TO_DEGREE
                pixel_max_lat = pixel_min_lat + KM_TO_DEGREE
                pixel_min_lon = min_lon + col * KM_TO_DEGREE
                pixel_max_lon = pixel_min_lon + KM_TO_DEGREE

                pixel_bbox = f"{pixel_min_lat},{pixel_min_lon},{pixel_max_lat},{pixel_max_lon}"

                # Create filter
                cql_filter = f"behavior_column='{behavior}'"

                params = {
                    "SERVICE": "WMS",
                    "REQUEST": "GetFeatureInfo",
                    "LAYERS": "ais:density",
                    "STYLES": "",
                    "FORMAT": "image/png",
                    "TRANSPARENT": "TRUE",
                    "version": "1.3.0",
                    "WIDTH": 256,
                    "HEIGHT": 256,
                    "CRS": "EPSG:4326",
                    "bbox": pixel_bbox,
                    "time": time,
                    "cql_filter": cql_filter,
                    "query_layers": "ais:density",
                    "info_format": "application/vnd.geo+json",
                    "feature_count": 1,
                    "I": 64,
                    "J": 196
                }

                tasks.append(fetch_density_data(session, params))

        responses = await asyncio.gather(*tasks)

        for response in responses:
            if "features" in response and len(response["features"]) > 0:
                density_value = response["features"][0]["properties"].get("DEFAULT")
                # Calculate Ship Count
                if density_value is not None:
                    density_value = float(density_value)  # Convert density to a float
                    ship_count = int(density_value * PIXEL_AREA_KM2 / T_avg)  # Convert to integer
                else:
                    ship_count = None

                output_data.append({
                    "Date": time,
                    "Pixel BBox": pixel_bbox,
                    "Density (Hours per Square Kilometer)": density_value,
                    "Ship Count": ship_count
                })
            else:
                print(f"No features found for {time}, Pixel BBox: {pixel_bbox}. Response: {response}")

    return output_data

async def get_density_data(bbox, year, month, behavior):
    output_data = []

    days_in_month = monthrange(year, month)[1]  # Get days in the selected month
    for day in range(1, days_in_month + 1):
        daily_data = await get_density_data_for_day(bbox, year, month, behavior, day)
        output_data.extend(daily_data)

    return output_data

# User input
bbox = input("Enter the bounding box (format: min_lat,min_lon,max_lat,max_lon): ")
year = int(input("Enter the year (e.g., 2024): "))
month = int(input("Enter the month (1-12): "))
behavior = input("Enter the vessel behavior (Loitering or NonLoitering): ")
output_file = input("Enter the output CSV file name base (e.g., density_data): ")

# Call the function
results = await get_density_data(bbox, year, month, behavior)

# Save results to a CSV file
df = pd.DataFrame(results)
df.to_csv(f"{output_file}.csv", index=False)
print(f"Data saved to {output_file}.csv")