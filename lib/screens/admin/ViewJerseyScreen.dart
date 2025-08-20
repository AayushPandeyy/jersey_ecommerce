import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jersey_ecommerce/models/JerseyModel.dart';
import 'package:jersey_ecommerce/screens/admin/AddJerseyScreen.dart';
import 'package:jersey_ecommerce/screens/admin/JerseyDetailsPage.dart';

class ViewJerseysPage extends StatefulWidget {
  const ViewJerseysPage({Key? key}) : super(key: key);

  @override
  State<ViewJerseysPage> createState() => _ViewJerseysPageState();
}

class _ViewJerseysPageState extends State<ViewJerseysPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<JerseyModel> jerseys = [];
  List<JerseyModel> filteredJerseys = [];
  bool isLoading = true;
  String searchQuery = '';
  double minPrice = 0;
  double maxPrice = 200;
  double selectedMinPrice = 0;
  double selectedMaxPrice = 200;
  bool showFilters = false;

  // Stream for jerseys
  Stream<List<JerseyModel>> getJerseysStream() {
    return FirebaseFirestore.instance
        .collection('Jersey')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JerseyModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  void initState() {
    super.initState();
    // No need to initialize stream here as it's handled by StreamBuilder
  }

  void _processJerseysData(List<JerseyModel> jerseysList) {
    try {
      jerseys = jerseysList;

      // Update price range based on actual data
      if (jerseys.isNotEmpty) {
        final prices = jerseys.map((j) => j.jerseyPrice).toList();
        final newMinPrice = prices.reduce((a, b) => a < b ? a : b);
        final newMaxPrice = prices.reduce((a, b) => a > b ? a : b);

        // Update price range if it has changed
        if (newMinPrice != minPrice || newMaxPrice != maxPrice) {
          minPrice = newMinPrice;
          maxPrice = newMaxPrice;

          // Update selected range if it's the first time
          if (selectedMinPrice == 0 && selectedMaxPrice == 200) {
            selectedMinPrice = minPrice;
            selectedMaxPrice = maxPrice;
          }
        }
      }

      // Filter jerseys without calling setState
      filteredJerseys = jerseys.where((jersey) {
        final matchesSearch =
            jersey.jerseyTitle.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            jersey.jerseyDescription.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
        final matchesPrice =
            jersey.jerseyPrice >= selectedMinPrice &&
            jersey.jerseyPrice <= selectedMaxPrice;
        return matchesSearch && matchesPrice;
      }).toList();

      isLoading = false;
    } catch (e) {
      // Don't show error during build, just log it
      print('Error processing jerseys data: $e');
      isLoading = false;
    }
  }

  void _filterJerseys() {
    setState(() {
      filteredJerseys = jerseys.where((jersey) {
        final matchesSearch =
            jersey.jerseyTitle.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            jersey.jerseyDescription.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
        final matchesPrice =
            jersey.jerseyPrice >= selectedMinPrice &&
            jersey.jerseyPrice <= selectedMaxPrice;
        return matchesSearch && matchesPrice;
      }).toList();
    });
  }

  void _sortJerseys(String sortBy) {
    setState(() {
      switch (sortBy) {
        case 'price_low':
          filteredJerseys.sort(
            (a, b) => a.jerseyPrice.compareTo(b.jerseyPrice),
          );
          break;
        case 'price_high':
          filteredJerseys.sort(
            (a, b) => b.jerseyPrice.compareTo(a.jerseyPrice),
          );
          break;
        case 'rating':
          filteredJerseys.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'name':
          filteredJerseys.sort(
            (a, b) => a.jerseyTitle.compareTo(b.jerseyTitle),
          );
          break;
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Widget _buildJerseyDetailsSheet(JerseyModel jersey) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jersey Image
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        jersey.jerseyImage != null &&
                            jersey.jerseyImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              jersey.jerseyImage[0]!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.sports_soccer,
                                  size: 80,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.sports_soccer,
                            size: 80,
                            color: Colors.grey,
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Jersey Title
                  Text(
                    jersey.jerseyTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Rating and Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < jersey.rating.floor()
                                  ? Icons.star
                                  : index < jersey.rating
                                  ? Icons.star_half
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${jersey.rating}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${jersey.jerseyPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    jersey.jerseyDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: Navigate to edit jersey page
                            _showSuccessSnackBar('Edit jersey functionality');
                          },
                          child: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteConfirmation(jersey);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(JerseyModel jersey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Jersey'),
        content: Text(
          'Are you sure you want to delete "${jersey.jerseyTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteJersey(jersey);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteJersey(JerseyModel jersey) async {
    try {
      await _firestore.collection('Jersey').doc(jersey.jerseyId).delete();
      _showSuccessSnackBar('Jersey deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Error deleting jersey: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Jerseys',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(showFilters ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _filterJerseys();
              },
              decoration: InputDecoration(
                hintText: 'Search jerseys...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Filter Section
          if (showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  RangeSlider(
                    values: RangeValues(selectedMinPrice, selectedMaxPrice),
                    min: minPrice,
                    max: maxPrice,
                    divisions: 20,
                    labels: RangeLabels(
                      '\$${selectedMinPrice.round()}',
                      '\$${selectedMaxPrice.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        selectedMinPrice = values.start;
                        selectedMaxPrice = values.end;
                      });
                    },
                    onChangeEnd: (values) {
                      _filterJerseys();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${selectedMinPrice.round()}'),
                      Text('\$${selectedMaxPrice.round()}'),
                    ],
                  ),
                ],
              ),
            ),

          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredJerseys.length} jerseys found',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (searchQuery.isNotEmpty ||
                    selectedMinPrice != minPrice ||
                    selectedMaxPrice != maxPrice)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        selectedMinPrice = minPrice;
                        selectedMaxPrice = maxPrice;
                        filteredJerseys = jerseys;
                      });
                    },
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // Jerseys Grid with StreamBuilder
          Expanded(
            child: StreamBuilder<List<JerseyModel>>(
              stream: getJerseysStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading jerseys',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No jerseys found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Process the real-time data
                _processJerseysData(snapshot.data!);

                return filteredJerseys.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No jerseys match your filters',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: filteredJerseys.length,
                        itemBuilder: (context, index) {
                          final jersey = filteredJerseys[index];
                          return _buildJerseyCard(jersey);
                        },
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add jersey page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJerseyPage()),
          );
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildJerseyCard(JerseyModel jersey) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JerseyDetailsPage(jersey: jersey),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jersey Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child:
                    jersey.jerseyImage != null && jersey.jerseyImage!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          jersey.jerseyImage[0]!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.sports_soccer,
                              size: 50,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.sports_soccer,
                        size: 50,
                        color: Colors.grey,
                      ),
              ),
            ),

            // Jersey Details
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Jersey Title
                    Text(
                      jersey.jerseyTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < jersey.rating.floor()
                                ? Icons.star
                                : index < jersey.rating
                                ? Icons.star_half
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '${jersey.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Price
                    Text(
                      '\$${jersey.jerseyPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      'In Stock : ${jersey.stock.toString()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
