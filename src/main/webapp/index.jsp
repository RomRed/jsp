<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Facture to pdf</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <style>
        body {
            background-color: #f8f9fa;
            padding-top: 20px;
        }
        .form-container {
            background-color: #fff;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .btn-pdf {
            margin-left: 10px;
        }
    </style>
</head>
<body>
<div class="container text-center mb-5">
    <h1>FACTURE TO PDF</h1>
</div>
<div class="container form-container">
    <form>

        <div id="products-container">
            <div class="product">
                <div class="form-group row">
                    <label for="nom_produit" class="col-sm-2 col-form-label">Nom produit :</label>
                    <div class="col-sm-10">
                        <input id="nom_produit" type="text" class="form-control nom_produit" placeholder="Entrez le nom du produit">
                    </div>
                </div>
                <div class="form-group row">
                    <label for="prix" class="col-sm-2 col-form-label">Prix HT :</label>
                    <div class="col-sm-10">
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text">€</span>
                            </div>
                            <input id="prix" type="text" class="form-control prix" placeholder="Entrez le prix HT">
                        </div>
                    </div>
                </div>
                <div class="form-group row">
                    <label for="quantite" class="col-sm-2 col-form-label">Quantité :</label>
                    <div class="col-sm-10">
                        <input id="quantite" type="text" class="form-control quantite" placeholder="Entrez la quantité">
                    </div>
                </div>
                <div class="form-group row">
                    <label for="tva" class="col-sm-2 col-form-label">TVA :</label>
                    <div class="col-sm-10">
                        <select class="form-control tva" id="tva">
                            <option value="0.055">5.5%</option>
                            <option value="0.05">5%</option>
                            <option value="0.1">10%</option>
                            <option value="0.2">20%</option>
                        </select>
                    </div>
                </div>
                <div class="form-group row">
                    <label for="total_article_ht" class="col-sm-2 col-form-label">Total HT :</label>
                    <div class="col-sm-10">
                        <input id="total_article_ht" type="text" class="form-control total_article_ht" readonly>
                    </div>
                </div>
                <div class="form-group row">
                    <label for="total_article" class="col-sm-2 col-form-label">Total TTC :</label>
                    <div class="col-sm-10">
                        <input id="total_article" type="text" class="form-control total_article" readonly>
                    </div>
                </div>
            </div>
        </div>

        <div class="form-group row">
            <label for="total_commande_ht" class="col-sm-2 col-form-label">Total Commande HT :</label>
            <div class="col-sm-10">
                <input type="text" class="form-control" id="total_commande_ht" readonly>
            </div>
        </div>
        <div class="form-group row">
            <label for="total_commande" class="col-sm-2 col-form-label">Total Commande TTC :</label>
            <div class="col-sm-10">
                <input type="text" class="form-control" id="total_commande" readonly>
            </div>
        </div>
        <div class="form-group row">
            <div class="col-sm-10 offset-sm-2 d-flex justify-content-center">
                <button type="submit" class="btn btn-primary">Envoyer</button>
                <button type="button" class="btn btn-secondary btn-pdf" id="btn-pdf">Convertir en PDF</button>
                <button type="button" class="btn btn-success" id="add-product">Ajouter un produit</button>
            </div>
        </div>
    </form>
</div>
<br/>


<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.68/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.68/vfs_fonts.js"></script>


<script>

    // Fonction pour calculer le total TTC pour tous les produits
    function calculerTotalTTC() {
        let totalTTC = 0;
        let totalHT = 0;
        // Parcourir tous les produits et calculer le total TTC et total HT
        document.querySelectorAll('.product').forEach(function(product) {
            let prixHT = parseFloat(product.querySelector('.prix').value);
            let quantite = parseFloat(product.querySelector('.quantite').value);
            let tva = parseFloat(product.querySelector('.tva').value);
            let totalHTArticle = prixHT * quantite;
            let totalTTCArticle = totalHTArticle * (1 + tva);
            totalHT += totalHTArticle;
            totalTTC += totalTTCArticle;
            product.querySelector('.total_article_ht').value = totalHTArticle.toFixed(2) + ' €';
            product.querySelector('.total_article').value = totalTTCArticle.toFixed(2) + ' €';
        });
        document.getElementById('total_commande_ht').value = totalHT.toFixed(2) + ' €';
        document.getElementById('total_commande').value = totalTTC.toFixed(2) + ' €';
    }

    // Fonction pour générer le PDF avec tous les produits
    function genererPDF() {
        let numeroFacture = 'FACT-' + Date.now();
        let produits = [];

        // Parcourir tous les produits et récupérer leurs valeurs
        document.querySelectorAll('.product').forEach(function(product) {
            let nomProduit = product.querySelector('.nom_produit').value;
            let prixHT = parseFloat(product.querySelector('.prix').value);
            let quantite = parseFloat(product.querySelector('.quantite').value);
            let tva = parseFloat(product.querySelector('.tva').value);
            let totalHTArticle = prixHT * quantite;
            let totalTTCArticle = totalHTArticle * (1 + tva);

            produits.push([nomProduit, quantite, prixHT.toFixed(2) + ' €', (tva * 100).toFixed(2) + '%', totalHTArticle.toFixed(2) + ' €', totalTTCArticle.toFixed(2) + ' €']);
        });

        let docDefinition = {
            // Contenu de la facture avec tous les produits
            content: [
                // En-tête de la facture
                { text: 'Facture', style: 'header', alignment: 'center', margin: [0, 0, 0, 20] },

                [
                    { text: 'numero de facture : '  + numeroFacture},
                    { text: 'Votre nom / Votre entreprise', style: 'subheader' },
                    { text: '123 Adresse de la rue', margin: [0, 5] },
                    { text: 'Ville, CP', margin: [0, 5] },
                    { text: 'Pays', margin: [0, 5] },
                    { text: 'Email: email@example.com', margin: [0, 5] },
                    { text: 'Téléphone: +1234567890', margin: [0, 5] }
                ],
                { text: '', margin: [0, 20] },
                // Tableau des produits
                {
                    table: {
                        body: [
                            ['Description', 'Quantité', 'Prix unitaire HT (€)', 'TVA', 'Total HT (€)', 'Total TTC (€)'],
                            // Ajoute les lignes pour chaque produit
                            ...produits
                        ],
                        widths: ['*', 'auto', 'auto', 'auto', 'auto', 'auto']
                    },
                    layout: 'lightHorizontalLines'
                },
                // Total Commande
                { text: 'Total Commande HT: ' + document.getElementById('total_commande_ht').value, margin: [0, 20] },
                { text: 'Total Commande TTC: ' + document.getElementById('total_commande').value, margin: [0, 20] }
            ],
            // Styles de la facture
            styles: {
                header: {
                    fontSize: 24,
                    bold: true
                },
                subheader: {
                    fontSize: 14,
                    bold: true
                }
            }
        };

        // Créer et télécharge le PDF
        pdfMake.createPdf(docDefinition).download('facture_' + numeroFacture + '.pdf');
    }

    // Écouteur d'événement pour le bouton "Ajouter un produit"
    document.getElementById('add-product').addEventListener('click', function() {
        // Cloner le premier produit et l'ajouter à la fin du conteneur des produits
        let productClone = document.querySelector('.product').cloneNode(true);
        document.getElementById('products-container').appendChild(productClone);

        // Ajouter des écouteurs d'événements pour les nouveaux champs de produit clonés
        productClone.querySelector('.prix').addEventListener('change', calculerTotalTTC);
        productClone.querySelector('.quantite').addEventListener('change', calculerTotalTTC);
        productClone.querySelector('.tva').addEventListener('change', calculerTotalTTC);
    });

    // Ajouter des écouteurs d'événements pour les champs de produit initiaux
    document.querySelectorAll('.product').forEach(function(product) {
        product.querySelector('.prix').addEventListener('change', calculerTotalTTC);
        product.querySelector('.quantite').addEventListener('change', calculerTotalTTC);
        product.querySelector('.tva').addEventListener('change', calculerTotalTTC);
    });

    document.querySelector('.btn-pdf').addEventListener('click', function() {
        genererPDF();
    });
</script>

</body>
</html>
