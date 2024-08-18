import 'dart:developer';
import 'dart:io';
import 'package:filemanager/presentation/bloc/search/search_bloc.dart';
import 'package:filemanager/presentation/bloc/selected_item/selected_items_cubit.dart';
import 'package:filemanager/presentation/widgets/item_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.directory});
  final String? directory;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late final Stopwatch _stopwatch;

  final List<FileSystemEntity> _oldItems = [];
  late final SelectedItemsCubit _selectedItemsCubit;
  @override
  void initState() {
    _selectedItemsCubit = context.read<SelectedItemsCubit>();
    _controller = TextEditingController();
    _stopwatch = Stopwatch()..start();
    super.initState();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _selectedItemsCubit.clear();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: FocusNode()..requestFocus(),
          decoration: InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            suffixIcon: IconButton(
                onPressed: () {
                  _controller.clear();
                  context.read<SearchBloc>().add(const SearchClear());
                },
                icon: const Icon(Icons.close)),
          ),
          onSubmitted: (value) {
            context.read<SearchBloc>().add(SearchFile(widget.directory, value));
          },
        ),
      ),
      body: BlocListener<SearchBloc, SearchState>(
        listenWhen: (previous, current) {
          if (current is SearchLoaded) {
            final result = _stopwatch.elapsedMilliseconds > 500 ||
                (_oldItems.length - current.searchResults.length).abs() > 15;
            _stopwatch.reset();
            return result;
          }
          _stopwatch.reset();
          return false;
        },
        listener: (context, state) {
          if (state is SearchLoaded) {
            final newItems = state.searchResults;

            final addedItems =
                newItems.where((item) => !_oldItems.contains(item)).toList();
            final removedItems =
                _oldItems.where((item) => !newItems.contains(item)).toList();

            for (var removedItem in removedItems) {
              final index = _oldItems.indexOf(removedItem);
              _oldItems.removeAt(index);
              _listKey.currentState?.removeItem(
                index,
                (context, animation) => ItemListTile(file: removedItem),
              );
            }

            for (var addedItem in addedItems) {
              _oldItems.add(addedItem);
              _listKey.currentState?.insertItem(_oldItems.length - 1);
            }
          }
        },
        child: AnimatedList(
          key: _listKey,
          initialItemCount: _oldItems.length,
          itemBuilder: (context, index, animation) {
            log('rebilding $index');
            return SizeTransition(
              sizeFactor: animation,
              child: ItemListTile(file: _oldItems[index]),
            );
          },
        ),
      ),
    );
  }
}
