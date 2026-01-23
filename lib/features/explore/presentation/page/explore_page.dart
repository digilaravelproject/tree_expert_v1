import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/routes/app_routes.dart';
import 'package:tree_expert/widgets/custom_image_view.dart';
import 'package:tree_expert/widgets/custom_scaffold.dart';
import '../../../projects/data/model/project_list_model.dart';
// import project model

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int selectedCategoryIndex = 0;
  ProjectListModel? project;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['project'] != null) {
      project = Get.arguments['project'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectName = project?.projectName ?? "Project Details";

    return CustomScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          projectName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {
               // Filter or Search trees
            },
            icon: const Icon(CupertinoIcons.search),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filters (Tree Species or Categories)
            _buildCategoryFilter(),
            const SizedBox(height: 20),

            // Recent Trees Section
            _buildSectionHeader(context, "Recent Trees", onViewAll: () {}),
            const SizedBox(height: 10),
            _buildHorizontalTreeGrid(context, recentTrees),
            const SizedBox(height: 24),

            // Nearby Trees Section
            _buildSectionHeader(context, "Nearby Trees", onViewAll: () {}),
            const SizedBox(height: 10),
            _buildHorizontalTreeGrid(context, nearbyTrees),
            const SizedBox(height: 24),

            // Featured Trees (e.g. Heritage Trees)
            _buildSectionHeader(context, "Heritage / Old Trees", onViewAll: () {}),
            const SizedBox(height: 10),
            _buildFeaturedTrees(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    required VoidCallback onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              "View All",
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalTreeGrid(
    BuildContext context,
    List<TreeExploreModel> trees,
  ) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.28,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: trees.length,
        itemBuilder: (context, index) {
          return _buildTreeCard(context, trees[index]);
        },
      ),
    );
  }

  Widget _buildTreeCard(BuildContext context, TreeExploreModel tree) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          // Background Image with Gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomImageView(
                  url: tree.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(CupertinoIcons.tree, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
          ),

          // Content Overlay
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tree.condition == "Good" ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tree.condition,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (tree.isVerified)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(Icons.check, size: 10, color: Colors.white),
                      ),
                  ],
                ),

                // Bottom Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: _buildInfoBadge(context, "Tree #${tree.treeNo}", Colors.white24)),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        tree.commonName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Center(
                      child: Text(
                        tree.scientificName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFeaturedTrees(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildFeaturedCard(context, featuredTrees[0]),
          const SizedBox(height: 12),
          _buildFeaturedCard(context, featuredTrees[1]),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, TreeExploreModel tree) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            CustomImageView(
              url: tree.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tree.commonName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                         Text(
                            tree.scientificName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Tree #${tree.treeNo} • ${tree.condition}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: () {
                             // View details
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy Tree Data Model
class TreeExploreModel {
  final String treeNo;
  final String commonName;
  final String scientificName;
  final String imageUrl;
  final String condition;
  final bool isVerified;
  final String family;

  TreeExploreModel({
    required this.treeNo,
    required this.commonName,
    required this.scientificName,
    required this.imageUrl,
    this.condition = "Good",
     this.isVerified = false,
     this.family = "",
  });
}

// Dummy Data
final List<TreeExploreModel> recentTrees = [
  TreeExploreModel(
    treeNo: "101",
    commonName: "Neem",
    scientificName: "Azadirachta indica",
    imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Neem_Tree.jpg/800px-Neem_Tree.jpg",
    condition: "Good",
    isVerified: true,
  ),
  TreeExploreModel(
    treeNo: "102",
    commonName: "Banyan",
    scientificName: "Ficus benghalensis",
    imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Banyan_Tree_Ficus_benghalensis.jpg/800px-Banyan_Tree_Ficus_benghalensis.jpg",
    condition: "Medium",
  ),
  TreeExploreModel(
    treeNo: "103",
    commonName: "Mango",
    scientificName: "Mangifera indica",
    imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Mango_tree_prom.JPG/800px-Mango_tree_prom.JPG",
    condition: "Good",
    isVerified: true,
  ),
  TreeExploreModel(
    treeNo: "104",
    commonName: "Peepal",
    scientificName: "Ficus religiosa",
    imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Ficus_religiosa_in_Hong_Kong.jpg/800px-Ficus_religiosa_in_Hong_Kong.jpg",
    condition: "Poor",
  ),
];

final List<TreeExploreModel> nearbyTrees = [
  TreeExploreModel(
    treeNo: "205",
    commonName: "Gulmohar",
    scientificName: "Delonix regia",
    imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Delonix_regia_1.jpg/800px-Delonix_regia_1.jpg",
    condition: "Good",
    isVerified: true,
  ),
  TreeExploreModel(
    treeNo: "206",
    commonName: "Ashoka",
    scientificName: "Saraca asoca",
    imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Saraca_asoca.jpg/800px-Saraca_asoca.jpg",
    condition: "Good",
  ),
];

final List<TreeExploreModel> featuredTrees = [
  TreeExploreModel(
    treeNo: "001",
    commonName: "Great Banyan",
    scientificName: "Ficus benghalensis",
    imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Banyan_Tree_Ficus_benghalensis.jpg/800px-Banyan_Tree_Ficus_benghalensis.jpg",
    condition: "Excellent",
    isVerified: true,
  ),
   TreeExploreModel(
    treeNo: "050",
    commonName: "Sacred Peepal",
    scientificName: "Ficus religiosa",
    imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Ficus_religiosa_in_Hong_Kong.jpg/800px-Ficus_religiosa_in_Hong_Kong.jpg",
    condition: "Good",
    isVerified: true,
  ),
];

final List<String> categories = [
  "All Trees",
  "Native",
  "Transplanted",
  "Heritage",
  "Endangered",
];
