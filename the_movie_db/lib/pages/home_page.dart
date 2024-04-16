import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_db/repositories/movie_repository_impl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: context.read<MovieRepositoryImpl>().getUpcoming(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CircularProgressIndicator(),
              ),
            );
          }

          var data = snapshot.data;

          if (data?.isEmpty ?? true) {
            return const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Text(
                    'Preencha o arquivo .env na raiz do projeto com a API_KEY e TOKEN para que as requisições possam e ser autenticadas corretamente, assim voce poderá consultar sua avaliações de favoritos posteriormente.',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            itemCount: data?.length ?? 0,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 2,
              crossAxisCount: 2,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 2,
            ),
            itemBuilder: (context, index) {
              _rating = data![index].voteAverage;
              return GestureDetector(
                onTap: () {
                  print('Image clicked!');
                },
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    FadeInImage(
                      fadeInCurve: Curves.bounceInOut,
                      fadeInDuration: const Duration(milliseconds: 500),
                      image: NetworkImage(data![index].getPostPathUrl()),
                      placeholder: const AssetImage('assets/images/logo.png'),
                    ),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 10,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                        _showRatingDialog(context, rating, data![index].id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRatingDialog(BuildContext context, double rating, int movieId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enviar avaliação'),
          content: Text('Deseja enviar a avaliação com a nota $rating?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _sendRating(rating, movieId);
                Navigator.of(context).pop();
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _sendRating(double rating, int movieId) async {
    bool isSuccess = await context.read<MovieRepositoryImpl>().addRating(movieId.toString(), rating);
    if (isSuccess) {
      print('Avaliado com Sucesso.');
    } else {
      print('Falha ao Avaliar.');
    }
  }
}