//HomeScreen

import React, { Component } from 'react';
import {
  StyleSheet,
  Text,
  View,
  Dimensions,
} from 'react-native';
import { strings } from '../../Helpers/Localization+Helper'
import { images } from '../../Helpers/Image+Helper'
import { DrawerActions } from "react-navigation"
import MovieService from '../../services/MovieService'
import DrawerLabel from '../../Navigation/DrawerLabel'
import NavigationView from '../../Navigation/NavigationView'
import MediaCell from './MediaCell/MediaCell'
import GridView from '../../components/GridView/GridView'
import { EventRegister } from 'react-native-event-listeners'
import DeviceInfo from '../../Helpers/DeviceInfo'

//Screens
import MovieCardScreen from '../MovieCardScreen/MovieCardScreen'

console.ignoredYellowBox = ['Remote debugger'];

const MOVIES_PER_ROW_PORTRAIT = 3;
const MOVIES_PER_ROW_LANDSCAPE = 4;

export class HomeScreen extends Component {

  static navigationOptions = {
    drawerLabel: (
      <DrawerLabel label={strings.moviesTitle} icon={images.moviesIcon.uri} />
    )
  };

  //Props
  constructor(props) {
    super(props);

    this.state = {
      mediaData: MovieService.getInstance().getMovieData(),
      loaded: MovieService.getInstance().getLoaded(),
      pages: MovieService.getInstance().getPage(),
      portraitOrientation: DeviceInfo.sharedInstance().isPortrait(),
    }
  }

  //Life-Cycle
  componentWillMount() {

    this.listener = EventRegister.addEventListener('updatedMovieData', () => {
      this.setState({
        mediaData: MovieService.getInstance().getMovieData(),
        pages: MovieService.getInstance().getLoaded(),
        loaded: MovieService.getInstance().getLoaded(),
      });
    })

    // Event Listener for orientation changes
    Dimensions.addEventListener('change', () => {
      this.setState({
        portraitOrientation: DeviceInfo.sharedInstance().isPortrait(),
      });
    });
  }

  componentWillUnmount() {
    EventRegister.removeEventListener(this.listener)
  }

  //Private
  onReachedBottom() {
    MovieService.getInstance().loadFilmList();
  }

  //Rendering
  renderLoadingView() {
    return (
      <View>
        <Text>
          Loading movies...
        </Text>
      </View>
    );
  }

  showMovieCard(movie){

    const { navigation } = this.props
    
    if(typeof navigation !== "undefined") {
      navigation.push('MovieCardScreen', {movie : movie})
    }
  }

  renderItem(item) {
    return  <MediaCell movie={item}
    onPressMovieCell={
      this.showMovieCard.bind(this, item)}
    />
  }

  render() {
    if (!this.state.loaded) {
      return this.renderLoadingView();
    }

    return (
      <View style={styles.mainContainer}>
        <NavigationView
          backgroundColor="rgba(90, 54, 217, 0.0)"
          leftButton={images.menuIcon.uri}
          rightButton={images.seacrhIcon.uri}
          titleLabel={strings.moviesTitle}
          onPressLeftButton={() => {
            if (!this.props.navigation.state.isDrawerOpen) {
              this.props.navigation.dispatch(DrawerActions.openDrawer());
            } else {
              this.props.navigation.dispatch(DrawerActions.closeDrawer());
            }
          }}
          onPressRightButton={this.onPressToolsButton}
        />
        <GridView
          style={styles.listView}
          items={this.state.mediaData}
          itemsPerRow={this.state.portraitOrientation ? MOVIES_PER_ROW_PORTRAIT : MOVIES_PER_ROW_LANDSCAPE}
          renderItem={this.renderItem.bind(this)}
          onEndReached={this.onReachedBottom}
          selectionMode={true}
        />
      </View>
    );
  }
}

var styles = StyleSheet.create({
  mainContainer: {
    backgroundColor: 'black',
    flex: 1,
  },
  listView: {
    flex: 2,
    backgroundColor: 'black',
    paddingTop: 10,
  },
});

