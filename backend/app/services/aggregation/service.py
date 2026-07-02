from typing import List, Dict, Any, Optional
from .providers import DocumentationProvider, YouTubeProvider, GitHubProvider

class AggregationService:
    def __init__(self):
        # Register connectors registry
        self.providers = [
            DocumentationProvider(),
            YouTubeProvider(),
            GitHubProvider()
        ]

    def aggregate_resources(
        self,
        career_slug: str,
        query: str = "",
        provider_filter: Optional[str] = None,
        difficulty_filter: Optional[str] = None,
        page: int = 1,
        page_size: int = 10
    ) -> Dict[str, Any]:
        results = []
        
        # 1. Fetch from each registered connector
        for provider in self.providers:
            # Skip if specific provider filter is set
            if provider_filter and provider_filter.lower() not in provider.provider_name.lower():
                # Allow partial matches e.g. "YouTube", "Official Documentation"
                if provider_filter.lower() != "docs" or provider.provider_name != "Official Documentation":
                    continue
            try:
                fetched = provider.fetch_resources(career_slug, query)
                results.extend(fetched)
            except Exception as e:
                print(f"Error fetching from {provider.provider_name}: {e}")

        # 2. De-duplicate based on URL string values
        unique_results = []
        seen_urls = set()
        for item in results:
            url = item.get("url")
            if url not in seen_urls:
                seen_urls.add(url)
                unique_results.append(item)

        # 3. Filter by difficulty if parameter is set
        if difficulty_filter:
            unique_results = [r for r in unique_results if r["difficulty"].lower() == difficulty_filter.lower()]

        # 4. Rank resources by quality/popularity
        unique_results.sort(key=lambda x: x.get("popularity_score", 0.0), reverse=True)

        # 5. Support Pagination offsets
        total_items = len(unique_results)
        start_idx = (page - 1) * page_size
        end_idx = start_idx + page_size
        paginated_items = unique_results[start_idx:end_idx]

        return {
            "total_count": total_items,
            "page": page,
            "page_size": page_size,
            "results": paginated_items
        }

# Global singleton coordinator
aggregation_service = AggregationService()
